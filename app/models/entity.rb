class Entity < ApplicationRecord
  serialize :attachment, JSON

  acts_as_taggable_on :tags
  acts_as_paranoid

  belongs_to :kind
  belongs_to :collection
  belongs_to :creator,
    class_name: "User",
    foreign_key: :creator_id,
    optional: true
  belongs_to :updater,
    class_name: "User",
    foreign_key: :updater_id,
    optional: true

  has_many :identifiers, dependent: :destroy
  has_many :datings, class_name: "EntityDating", dependent: :destroy

  belongs_to :medium, dependent: :destroy, optional: true

  has_and_belongs_to_many :system_groups
  has_and_belongs_to_many :authority_groups
  has_and_belongs_to_many :user_groups

  has_many :out_rels, foreign_key: :from_id, class_name: 'Relationship', dependent: :destroy
  has_many :in_rels, foreign_key: :to_id, class_name: 'Relationship', dependent: :destroy

  has_many :outgoing_relationships, class_name: "DirectedRelationship", foreign_key: :from_id
  has_many :outgoing, through: :outgoing_relationships, source: :to

  has_many :incoming_relationships, class_name: "DirectedRelationship", foreign_key: :to_id
  has_many :incoming, through: :incoming_relationships, source: :from

  accepts_nested_attributes_for :medium, :datings, allow_destroy: true

  validates :name,
    presence: {if: :needs_name?},
    uniqueness: {
      scope: [:kind_id, :distinct_name],
      allow_blank: true,
      case_sensitive: true
    },
    white_space: true
  validates :distinct_name,
    uniqueness: {
      scope: [:kind_id, :name],
      allow_blank: true,
      case_sensitive: true
    },
    white_space: true
  validates :kind, :uuid, :collection_id, presence: true
  validates :no_name_statement, inclusion: {
    allow_blank: true, in: ['unknown', 'not_available', 'empty_name', 'enter_name']
  }

  validate(
    :validate_distinct_name_needed, :validate_dataset, :validate_properties,
    :attached_file
  )

  def attached_file
    if is_medium?
      if medium
        unless medium.document.file? || medium.image.file?
          medium.errors.add :document, :needs_file
          medium.errors.add :image, :needs_file
        end
      else
        errors.add :medium, :needs_medium
      end
    end
  end

  def validate_distinct_name_needed
    if has_name_duplicates?
      duplicate_collection = find_name_duplicates.first.collection

      if duplicate_collection.id == collection_id
        errors.add :distinct_name
      else
        message = I18n.t(
          'activerecord.errors.messages.needed_for_disambiguation',
          collection: duplicate_collection.name
        )
        errors.add :distinct_name, message
      end
    end
  end

  def read_attribute_for_validation(attr)
    a = attr.to_s
    if a.match(/^dataset\./)
      dataset[a.split('\.')[1]]
    else
      super
    end
  end

  def attachment
    unless self[:attachment]
      self[:attachment] = {}
    end

    self[:attachment]
  end

  def schema
    kind ? kind.field_instances(self) : []
  end

  def dataset
    attachment['fields'] ||= {}
  end

  def dataset=(value)
    attachment['fields'] = value
  end

  def fields
    kind.field_instances(self)
  end

  def field_hashes
    fields.map{ |field| field.serializable_hash }
  end

  def synonyms
    (attachment['synonyms'].presence || []).uniq
  end

  def synonyms=(value)
    attachment['synonyms'] = case value
    when String then value.split("\n")
    when Array then value
    else
      raise "value '#{value.inspect} can't be assigned as synonyms"
    end
  end

  def properties
    attachment['properties'] ||= []
  end

  def properties=(value)
    attachment['properties'] = value
  end

  def validate_dataset
    schema.each do |field|
      result = field.validate_value
      if result != true
        errors.add "dataset.#{field.name}", result
      end
    end
  end

  def validate_properties
    properties.each do |property|
      errors.add :properties, :invalid_properties_format if property['label'].blank?
      errors.add :properties, :invalid_properties_format if property['value'].blank?
    end
  end

  before_validation :generate_uuid, :sanitize_distinct_name
  before_save :generate_uuid, :add_to_user_group
  after_commit :update_elastic, :update_identifiers

  def sanitize_distinct_name
    self.distinct_name = nil if distinct_name == ""
  end

  def generate_uuid
    self.uuid ||= SecureRandom.uuid
  end

  def update_elastic
    if Kor::Elastic.available?
      if deleted?
        Kor::Elastic.drop self
      else
        Kor::Elastic.index self, full: true
      end
    end
  end

  def update_identifiers
    if deleted?
      Identifier.where(entity_id: id).destroy_all
      # self.identifiers.destroy_all
    else
      kind = Kind.with_deleted.find_by(id: kind_id)

      kind.fields.identifiers.each do |field|
        field.entity = self
        if field.value.present?
          id = identifiers.find_or_create_by(kind: field.name)
          id.update value: field.value
        else
          id = identifiers.where(kind: field.name).first
          id.destroy if id
        end
      end
    end
  end

  def update_wikidata
    if Kor.settings['wikidata_integration'].present?
      qid = dataset['wikidata_id']
      if qid.present?
        Kor::Import::WikiData.find(qid).update(self)
      end
    end
  end

  def cache_key(*timestamp_names)
    timestamp = [
      created_at,
      updated_at,
      kind.created_at,
      kind.updated_at,
      collection.created_at,
      collection.updated_at
    ].max

    "#{model_name.cache_key}/#{id}-#{timestamp}"
  end

  attr_accessor :user_group_id

  def add_to_user_group
    if user_group_id
      user_group = UserGroup.find(user_group_id)
      self.user_group_id = nil
      user_group.add_entities self
    end
  end

  def mark_invalid
    SystemGroup.find_or_create_by(name: 'invalid').add_entities self
  end

  def mark_valid
    SystemGroup.find_or_create_by(name: 'invalid').remove_entities self
  end

  def last_updated_by
    updater || creator
  end

  def self.allowed(user, policy = :view)
    collections = Kor::Auth.authorized_collections(user, policy)
    where("entities.collection_id IN (?)", collections.map{ |c| c.id })
  end

  # re-enable this for display
  def html_comment
    red_cloth = RedCloth.new(comment || "")
    red_cloth.sanitize_html = true
    red_cloth.to_html
  end

  def degree
    Relationship.where("from_id = ? OR to_id = ?", id, id).count
  end

  def primary_relationships(user)
    relation_names = Relation.primary_relation_names
    if relation_names.empty?
      outgoing_relationships.none
    else
      outgoing_relationships.
        allowed(user).
        by_relation_name(relation_names).
        includes(to: [:tags, :collection, :kind, :medium])
    end
  end

  def secondary_relationships(user)
    relation_names = Relation.secondary_relation_names
    if relation_names.empty?
      outgoing_relationships.none
    else
      outgoing_relationships.
        allowed(user).
        by_relation_name(relation_names).
        includes(to: [:tags, :collection, :kind, :medium])
    end
  end

  def relation_counts(user, options = {})
    options.reverse_merge! media: false
    media_id = Kind.medium_kind_id

    scope = outgoing_relationships.
      order_by_relation_name.
      allowed(user, :view).
      includes(:to).
      group('directed_relationships.relation_name')

    if options[:media]
      scope = scope.where('tos.kind_id = ?', media_id)
    else
      scope = scope.where('tos.kind_id != ?', media_id)
    end

    scope.count
  end

  def media_count(user)
    outgoing_relationships.
      with_to.
      allowed(user, :view).
      where('tos.kind_id = ?', Kind.medium_kind_id).
      count
  end

  def media(user)
    @media ||= outgoing_relationships.
      by_to_kind(Kind.medium_kind_id).
      allowed(user).
      map{ |dr| dr.to }
  end

  # TODO: this used to grab the content type for media, removed because its
  # probably not needed anymore
  def kind_name(options = {})
    options.reverse_merge!(include_subtype: true)

    if options[:include_subtype]
      if is_medium?
        "#{kind.name} (#{medium.content_type})"
      else
        if subtype.present?
          "#{kind.name} (#{subtype})"
        else
          kind.name
        end
      end
    else
      kind.name
    end
  end

  def has_name_duplicates?
    find_name_duplicates.count > 0
  end

  def find_name_duplicates
    return [] unless needs_name?

    result = self.class.where(name: name, distinct_name: distinct_name, kind_id: kind_id)
    new_record? ? result : result.where("id != ?", id)
  end

  def needs_name?
    !is_medium? && no_name_statement == 'enter_name'
  end

  def display_name
    if is_medium?
      "#{Medium.model_name.human} #{id}"
    elsif no_name_statement == 'enter_name'
      distinct_name.blank? ? name : "#{name} (#{distinct_name})".strip
    else
      I18n.t("values.no_name_statements.#{no_name_statement}").capitalize
    end
  end

  def no_name_statement
    read_attribute(:no_name_statement) || 'enter_name'
  end

  def is_medium?
    !!medium_id || !!medium || kind_id == Kind.medium_kind_id
  end

  scope :by_ordered_id_array, lambda{ |*ids|
    if ids.present? && ids.flatten.compact.present?
      ids = ids.flatten.compact.map{ |id| connection.quote(id) }
      where(id: ids).order(Arel.sql("FIELD(id,#{ids.join(',')})"))
    else
      none
    end
  }
  scope :by_relation_name, lambda{ |relation_name|
    return all if relation_name.blank?

    where(kind_id: Relation.to_entity_kind_ids(relation_name))
  }
  scope :by_id, lambda{ |id| id.present? ? where(id: id) : all }
  scope :by_uuid, lambda{ |uuid| uuid.present? ? where(uuid: uuid) : all }
  scope :created_after, lambda{ |time| time.present? ? where("created_at > ?", time) : all }
  scope :created_before, lambda{ |time| time.present? ? where("created_at < ?", time) : all }
  scope :updated_after, lambda{ |time| time.present? ? where("updated_at > ?", time) : all }
  scope :updated_before, lambda{ |time| time.present? ? where("updated_at < ?", time) : all }
  scope :only_kinds, lambda{ |ids| ids.present? ? where("entities.kind_id IN (?)", ids) : all }
  scope :except_kinds, lambda{ |ids| ids.present? ? where("entities.kind_id NOT IN (?)", ids) : all }
  scope :latest, lambda{ |*args| where("created_at > ?", (args.first || 2.weeks).ago) }
  scope :within_collections, lambda{ |ids| ids.present? ? where("entities.collection_id IN (?)", ids) : all }
  scope :media, lambda{ only_kinds(Kind.medium_kind_id) }
  scope :without_media, lambda{ except_kinds(Kind.medium_kind_id) }
  scope :by_subtype, lambda{ |subtype| subtype.present? ? where(subtype: subtype) : all }
  scope :by_comment, lambda{ |comment| comment.present? ? where('comment LIKE ?', "%#{comment}%") : all }
  scope :created_by, lambda{ |id| id.present? ? where(creator_id: id) : all }
  scope :updated_by, lambda{ |id| id.present? ? where(updater_id: id) : all }
  scope :named_like, lambda{ |terms|
    if terms.present?
      terms = terms.split(/\s+/)
      sql = terms.map{ |_t| 'name LIKE ? OR distinct_name LIKE ?' }.join(' OR ')
      values = terms.map{ |t| "%#{t}%" }
      values = values + values
      where("(#{sql})", *values)
    else
      all
    end
  }
  scope :dated_in, lambda{ |datings|
    datings = [datings] unless datings.is_a?(Array)

    results = all
    if datings.present?
      sql = []
      values = []
      datings.each do |dating|
        if parsed = Dating.parse(dating)
          from = EntityDating.julian_date_for(parsed[:from])
          to = EntityDating.julian_date_for(parsed[:to])
          sql << '(entity_datings.to_day > ? AND entity_datings.from_day < ?)'
          values += [from, to]
        end
      end

      if sql.size > 0
        sql = "(#{sql.join ' OR '})"
        results = joins(:datings).distinct(:entity_id).where(sql, *values)
      end
    end
    results
  }
  scope :load_fully, lambda{ joins(:kind, :collection).includes(:medium) }
  scope :isolated, lambda{ |activate|
    return all unless activate.present?

    joins("LEFT JOIN directed_relationships rels ON entities.id = rels.from_id").
      where("rels.id IS NULL")
  }
  scope :within_authority_groups, lambda{ |ids|
    return all unless ids.present?

    joins('LEFT JOIN authority_groups_entities ae ON ae.entity_id = id').
      where('ae.authority_group_id IN (?)', ids)
  }
  scope :within_user_groups, lambda{ |ids|
    return all unless ids.present?

    joins('LEFT JOIN entities_user_groups eu ON eu.entity_id = id').
      where('eu.user_group_id IN (?)', ids)
  }
  scope :within_system_groups, lambda{ |ids|
    return all unless ids.present?

    joins('LEFT JOIN entities_system_groups es ON es.entity_id = id').
      where('es.system_group_id IN (?)', ids)
  }

  def self.tagged_with(tags = [])
    tags.present? ? super : all
  end

  def self.invalid(invalid)
    return all unless invalid.present?

    group = SystemGroup.find_or_create_by(name: 'invalid')
    within_system_groups(group.id)
  end

  def self.by_file_size(size, mode = :equal)
    return all if size.blank?

    op = {equal: '=', smaller: '<=', larger: '>='}[mode]

    includes(:medium).
      references(:media).
      where("media.image_file_size #{op} :s OR media.document_file_size #{op} :s", s: size)
  end

  def self.by_file_type(type)
    return all if type.blank?

    includes(:medium).
      references(:media).
      where('media.image_content_type = :t OR media.document_content_type = :t', t: type)
  end

  def self.by_file_name(name)
    return all if name.blank?

    includes(:medium).
      references(:media).
      where('media.image_file_name = :n OR media.document_file_name = :n', n: name)
  end

  def self.by_datahash(hash)
    return all if hash.blank?

    includes(:medium).
      references(:media).
      where('media.datahash = ?', hash)
  end
end
