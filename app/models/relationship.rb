class Relationship < ApplicationRecord
  serialize :properties

  acts_as_paranoid

  belongs_to :owner, class_name: "User", optional: true
  belongs_to :relation
  belongs_to :from, class_name: "Entity", foreign_key: :from_id
  belongs_to :to, class_name: "Entity", foreign_key: :to_id

  belongs_to :normal, {
    class_name: "DirectedRelationship",
    dependent: :destroy,
    autosave: true,
    optional: true
  }
  belongs_to :reversal, {
    class_name: "DirectedRelationship",
    dependent: :destroy,
    autosave: true,
    optional: true
  }

  has_many :datings, :class_name => "RelationshipDating", :dependent => :destroy

  validates :from_id, :to_id, presence: true
  validates :relation_id, presence: true, if: :to_id
  # validates_associated :datings

  before_validation :ensure_direction
  after_validation :ensure_uuid, :ensure_unique_properties, :ensure_directed
  after_save :connect_directed

  accepts_nested_attributes_for :datings, allow_destroy: true

  def ensure_unique_properties
    self.properties = self.properties.uniq
  end

  def ensure_uuid
    self.uuid ||= SecureRandom.uuid
  end

  def ensure_directed
    self.normal ||= DirectedRelationship.new
    self.reversal ||= DirectedRelationship.new

    self.normal.assign_attributes(
      from_id: self.from_id,
      to_id: self.to_id,
      relation_id: self.relation_id,
      relationship_id: self.id,
      is_reverse: false,
      relation_name: self.relation.try(:name)
    )

    self.reversal.assign_attributes(
      from_id: self.to_id,
      to_id: self.from_id,
      relation_id: self.relation_id,
      relationship_id: self.id,
      is_reverse: true,
      relation_name: self.relation.try(:reverse_name)
    )
  end

  def ensure_direction
    if @relation_name && self.from && self.to
      normal = Relation.find_by(
        from_kind_id: self.from.kind_id,
        name: @relation_name,
        to_kind_id: self.to.kind_id
      )

      if normal
        self.relation = normal
      else
        reverse = Relation.find_by(
          from_kind_id: self.to.kind_id,
          reverse_name: @relation_name,
          to_kind_id: self.from.kind_id
        )

        if reverse
          # we drop the stored relation name so that the next call to this
          # method works as well
          @relation_name = nil

          self.relation = reverse
          tmp = self.from
          self.from = self.to
          self.to = tmp
        else
          raise Kor::Exception, "no relation found for #{from.kind.name} -> #{@relation_name} -> #{to.kind.name}"
        end
      end
    end
  end

  def connect_directed
    if self.normal && !self.normal.destroyed?
      self.normal.update_column :relationship_id, self.id
      self.reversal.update_column :relationship_id, self.id
    end
  end

  scope :with_ends, lambda{
    joins("LEFT JOIN entities AS froms ON froms.id = relationships.from_id").
      joins("LEFT JOIN entities AS tos ON tos.id = relationships.to_id")
  }
  scope :allowed, lambda{ |user, policy|
    collection_ids = Kor::Auth.authorized_collections(user, policy).map{ |c| c.id }
    with_ends.where(
      "froms.collection_id in (:ids) AND tos.collection_id in (:ids)",
      :ids => collection_ids
    )
  }
  scope :updated_after, lambda{ |time| time.present? ? where("relationships.updated_at >= ?", time) : all }
  scope :updated_before, lambda{ |time| time.present? ? where("relationships.updated_at <= ?", time) : all }
  scope :inconsistent, lambda{
    all.
      joins('LEFT JOIN entities froms ON froms.id = relationships.from_id').
      joins('LEFT JOIN entities tos ON tos.id = relationships.to_id').
      joins('LEFT JOIN relations r ON relationships.relation_id = r.id').
      where('froms.kind_id != r.from_kind_id OR tos.kind_id != r.to_kind_id')
  }
  scope :dated_in, lambda{ |dating|
    if dating.present?
      if parsed = Dating.parse(dating)
        joins(:datings).
          distinct(:relationship_id).
          where(
            "relationship_datings.to_day > ?",
            Dating.julian_date_for(parsed[:from])
          ).
          where(
            "relationship_datings.from_day < ?",
            Dating.julian_date_for(parsed[:to])
          )
      else
        none
      end
    else
      all
    end
  }

  def self.relate_and_save(from_id, relation_name, to_id, properties = [])
    r = relate(from_id, relation_name, to_id, properties)
    r.save
    r
  end

  def self.relate(from_id, relation_name, to_id, properties = [])
    from_id = Kor.id_for_model(from_id)
    to_id = Kor.id_for_model(to_id)

    Relationship.new(
      :from_id => from_id,
      :relation_name => relation_name,
      :to_id => to_id,
      :properties => properties
    )
  end

  # This doesn probably not work as expected with/without properties
  def self.related?(from_id, relation_name, to_id, properties = nil)
    dr = DirectedRelationship.where(
      from_id: from_id,
      relation_name: relation_name,
      to_id: to_id
    ).first

    # TODO: this does not work
    if dr
      properties == nil || dr.properties == properties
    end
  end

  def has_properties?
    !properties.blank?
  end

  def properties
    unless self[:properties]
      self[:properties] = []
    end

    self[:properties]
  end

  def relation_name=(value)
    @relation_name = value
  end

  def human
    from_name = from.display_name.first(30)
    to_name = to.display_name.first(30)
    relation_name = (reverse ? relation.reverse_name : relation.name)
    r = (reverse ? 'reverse' : 'normal')
    "'#{from_name}' [#{r}] #{relation_name} '#{to_name}'"
  end

  def cache_key(*timestamp_names)
    timestamp = [
      created_at,
      updated_at,
      relation.created_at,
      relation.updated_at,
    ].max

    "#{model_name.cache_key}/#{id}-#{timestamp}"
  end

  # TODO: add method 'describe' that shows from_id - relation -> to_id with
  # and all that
end
