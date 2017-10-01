class Relationship < ActiveRecord::Base
  serialize :properties

  acts_as_paranoid
  
  belongs_to :owner, :class_name => "User"
  belongs_to :relation
  belongs_to :from, :class_name => "Entity", :foreign_key => :from_id
  belongs_to :to, :class_name => "Entity", :foreign_key => :to_id

  belongs_to :normal, class_name: "DirectedRelationship", dependent: :destroy, autosave: true
  belongs_to :reversal, class_name: "DirectedRelationship", dependent: :destroy, autosave: true

  has_many :datings, :class_name => "RelationshipDating", :dependent => :destroy

  validates :from_id, :to_id, :relation_id, presence: true
  validates_associated :datings
  
  before_validation :ensure_direction
  after_validation :ensure_uuid, :ensure_unique_properties, :ensure_directed
  after_commit :connect_directed

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

  def connect_directed
    if self.normal && !self.normal.destroyed?
      self.normal.update_column :relationship_id, self.id
      self.reversal.update_column :relationship_id, self.id
    end
  end

  # TODO: this is done before validation. should it not be done afterwards, so
  # that it doesn't send modified data back to the forms when it actually
  # doesn't validate?
  def ensure_direction
    if @relation_name
      if relation = Relation.where(name: @relation_name).first
        self.relation = relation
      elsif relation = Relation.where(reverse_name: @relation_name).first
        self.relation = relation
        tmp = self.from
        self.from = self.to
        self.to = tmp
      else
        raise "relation #{@relation_name} not found"
      end
    end
  end

  scope :pageit, lambda { |page, per_page|
    page = (page || 1) - 1
    per_page = [(per_page || 10).to_i, Kor.config['app']['max_results_per_request']].min
    limit(per_page).offset(per_page * page)
  }
  scope :with_ends, lambda {
    joins("LEFT JOIN entities AS froms ON froms.id = relationships.from_id").
    joins("LEFT JOIN entities AS tos ON tos.id = relationships.to_id")
  }
  scope :allowed, lambda{|user, policy|
    collection_ids = Kor::Auth.authorized_collections(user, policy).map{|c| c.id}
    with_ends.where(
      "froms.collection_id in (:ids) AND tos.collection_id in (:ids)",
      :ids => collection_ids
    )
  }
  scope :updated_after, lambda {|time| time.present? ? where("relationships.updated_at >= ?", time) : all}
  scope :updated_before, lambda {|time| time.present? ? where("relationships.updated_at <= ?", time) : all}
  scope :inconsistent, lambda {
    result = joins('LEFT JOIN directed_relationships dr ON relationships.normal_id = dr.id')
            .joins('LEFT JOIN entities froms ON froms.id = dr.from_id')
            .joins('LEFT JOIN entities tos ON tos.id = dr.to_id')
    conditions = []
    values = []

    Relation.all.each do |r|
      if r.from_kind_ids.present? && r.to_kind_ids.present?
        conditions << "(froms.kind_id IN (?) AND tos.kind_id IN (?))"
        values += [r.from_kind_ids, r.to_kind_ids]

        if r.name == r.reverse_name
          conditions << "(froms.kind_id IN (?) AND tos.kind_id IN (?))"
          values += [r.to_kind_ids, r.from_kind_ids]
        end
      end
    end

    result = result.where('NOT (' + conditions.join(' OR ') + ')', *values)
  }
  scope :dated_in, lambda {|dating|
    if dating.present?
      if parsed = Dating.parse(dating)
        joins(:datings).
        distinct(:relationship_id).
        where("relationship_datings.to_day > ?", Dating.julian_date_for(parsed[:from])).
        where("relationship_datings.from_day < ?", Dating.julian_date_for(parsed[:to]))
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

end
