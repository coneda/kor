class Kind < ApplicationRecord
  MEDIA_UUID = '93a03d5c-e439-4294-a8d4-d4921c4d0dbc'

  serialize :settings

  acts_as_paranoid

  has_many :entities, :dependent => :destroy
  has_many :fields, :dependent => :destroy
  has_many :generators, :dependent => :destroy

  has_many :kind_parent_inheritances, class_name: 'KindInheritance', foreign_key: :child_id, dependent: :destroy
  has_many :kind_child_inheritances, class_name: 'KindInheritance', foreign_key: :parent_id, dependent: :destroy
  has_many :parents, through: :kind_parent_inheritances
  has_many :children, through: :kind_child_inheritances

  validates :name,
    :presence => true,
    :uniqueness => true,
    :white_space => true

  validates :plural_name,
    :presence => true,
    :white_space => true

  validate do |kind|
    to_check = kind.parents.to_a
    cycle = false
    while (k = to_check.pop) && !cycle
      if k.id == kind.id
        cycle = true
      else
        to_check += k.parents.to_a
      end
    end

    if cycle
      kind.errors.add :parent_ids, :would_result_in_cycle
    end
  end

  default_scope lambda { order(:name) }
  scope :without_media, lambda { where('id != ?', Kind.medium_kind_id) }
  scope :updated_after, lambda { |time| time.present? ? where("updated_at >= ?", time) : all }
  scope :updated_before, lambda { |time| time.present? ? where("updated_at <= ?", time) : all }
  scope :allowed, lambda { |user, policies| all }
  scope :active, lambda { where(abstract: [false, nil]) }

  before_validation :generate_uuid

  def schema=(value)
    self[:schema] = value.presence
  end

  def parent_ids
    kind_parent_inheritances.pluck(:parent_id)
  end

  def parent_ids=(values)
    self.parents = Kind.where(id: values).to_a
  end

  def child_ids
    kind_child_inheritances.pluck(:child_id)
  end

  def deep_child_ids
    results = kind_child_inheritances.map do |kci|
      [kci.child_id] + kci.child.deep_child_ids
    end
    results.flatten.uniq
  end

  def child_ids=(values)
    self.children = Kind.where(id: values).to_a
  end

  def removable
    child_ids.empty? && !medium_kind? && entities.count == 0
  end

  def generate_uuid
    self.uuid ||= SecureRandom.uuid
  end

  def field_instances(object)
    self.fields.each do |field|
      field.entity = object
    end

    self.fields
  end

  def self.available_fields
    Dir["#{Rails.root}/app/models/fields/*.rb"].map do |f|
      underscore = f.split('/').last.gsub('.rb', '')
      "fields/#{underscore}".classify.constantize
    end
  end

  # TODO: still needed?
  def defines_schema?
    !self.fields.empty?
  end

  def medium_kind?
    uuid == MEDIA_UUID
  end

  def medium_kind?
    uuid == MEDIA_UUID
  end

  def self.medium_kind
    find_by(uuid: MEDIA_UUID)
  end

  def self.medium_kind_id
    @medium_kind_id ||= if m = select(:id).medium_kind
      m.id
    end
  end

  def self.find_ids(ids)
    find_all_by_id(ids).map { |k| k.id }
  end

  def self.all_ids
    all.collect { |k| k.id }
  end

  def self.for_select
    all.collect { |k| [k.name, k.id] }.sort do |x, y|
      x.first <=> y.first
    end
  end

  def settings
    if destroyed?
      (self[:settings] || {}).symbolize_keys
    else
      unless self[:settings]
        self[:settings] = {}
      end

      self[:settings].symbolize_keys!
    end
  end

  def settings=(values)
    self[:settings] ||= {}
    self[:settings].deep_merge!(values)
  end

  def name_label
    settings[:name_label].presence || Entity.human_attribute_name(:name)
  end

  def name_label=(value)
    settings[:name_label] = value
  end

  def tagging
    settings[:tagging] = true if settings[:tagging].nil?
    settings[:tagging]
  end

  def tagging=(value)
    settings[:tagging] = !!value
  end

  def dating_label
    settings[:dating_label] ||= EntityDating.model_name.human
  end

  def dating_label=(value)
    settings[:dating_label] = value
  end

  def distinct_name_label
    settings[:distinct_name_label].presence || Entity.human_attribute_name(:distinct_name)
  end

  def distinct_name_label=(value)
    settings[:distinct_name_label] = value
  end

  def requires_naming?
    !medium_kind?
  end

  def can_have_synonyms?
    settings[:synonyms] || requires_naming?
  end

  def serializable_hash(*args)
    super :methods => [:defines_schema?, :tagging]
  end
end
