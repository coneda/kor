# An instance of this class represents an entity kind. It therefor holds some
# settings, has many entities and allows the configuration of custom dataset
# attributes
class Kind < ActiveRecord::Base
  serialize :settings
  
  has_many :entities, :dependent => :destroy
  has_many :fields, :dependent => :destroy
  has_many :generators, :dependent => :destroy
  
  validates :name,
    :presence => true,
    :uniqueness => true,
    :white_space => true

  validates :plural_name,
    :white_space => true
  
  default_scope lambda { order(:name) }
  scope :without_media, lambda { where('id != ?', Kind.medium_kind.id) }
  
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
    find_by_name('Medium')
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
    settings[:naming] = true if settings[:naming].nil?
    settings[:naming]
  end
  
  def has_subtype?
    settings[:subtype]
  end
  
  def can_have_synonyms?
    settings[:synonyms] || requires_naming?
  end
  
  
  # Formats
  
  def serializable_hash(*args)
    super :methods => [:defines_schema?, :tagging]
  end

end
