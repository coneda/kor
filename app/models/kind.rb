class Kind < ActiveRecord::Base

  MEDIA_UUID = '93a03d5c-e439-4294-a8d4-d4921c4d0dbc'

  serialize :settings
  
  acts_as_paranoid
  
  has_many :entities, :dependent => :destroy
  has_many :fields, :dependent => :destroy
  has_many :generators, :dependent => :destroy
  
  validates :name,
    :presence => true,
    :uniqueness => true,
    :white_space => true

  validates :plural_name,
    :presence => true,
    :white_space => true
  
  default_scope lambda { order(:name) }
  scope :without_media, lambda { where('id != ?', Kind.medium_kind.id) }
  scope :updated_after, lambda {|time| time.present? ? where("updated_at >= ?", time) : all}
  scope :updated_before, lambda {|time| time.present? ? where("updated_at <= ?", time) : all}
  scope :allowed, lambda {|user, policies| all}

  before_validation :generate_uuid

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
  
  def defines_schema?
    !self.fields.empty?
  end
  
  # Other
  
  def self.medium_kind
    find_by(uuid: MEDIA_UUID)
  end

  def self.medium_kind_id
    @medium_kind_id ||= medium_kind.id
  end
  
  def self.find_ids(ids)
    find_all_by_id(ids).map{|k| k.id}
  end
  
  def self.all_ids
    all.collect{|k| k.id}
  end
  
  def self.for_select
    all.collect{ |k| [ k.name, k.id ] }.sort do |x,y|
      x.first <=> y.first
    end
  end
  
  
  # Settings
  
  def settings
    unless self[:settings]
      self[:settings] = {}
    end

    self[:settings].symbolize_keys!
  end
  
  def settings=(values)
    self[:settings] ||= {}
    self[:settings].deep_merge!(values)
  end
  
  def name_label
    settings[:name_label] ||= Entity.human_attribute_name(:name)
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
  
  def distinct_name_label
    settings[:distinct_name_label] ||= Entity.human_attribute_name(:distinct_name)
  end
  
  def requires_naming?
    self.class.medium_kind.id != id
  end
  
  def can_have_synonyms?
    settings[:synonyms] || requires_naming?
  end

  def serializable_hash(*args)
    super :methods => [:defines_schema?, :tagging]
  end

end
