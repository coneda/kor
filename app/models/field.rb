class Field < ActiveRecord::Base
  
  # ActiveRecord settings
  
  serialize :settings, Hash
  
  belongs_to :kind
  
  validates :name,
    :presence => true,
    :format => {:with => /\A[a-z0-9_]+\z/},
    :uniqueness => {:scope => :kind_id},
    :white_space => true
  validates_presence_of :show_label, :form_label, :search_label
  
  before_validation do |f|
    f.form_label = f.show_label if f.form_label.blank?
    f.search_label = f.show_label if f.search_label.blank?
  end

  after_save do |f|
    if f.is_identifier_changed?
      if f.is_identifier?
        self.delay.create_identifiers
      else
        Identifier.where(:kind => f.name).delete_all
      end
    end
  end

  def create_identifiers
    self.kind.entities.find_each :batch_size => 100 do |entity|
      entity.update_identifiers
    end
  end

  scope :identifiers, lambda { where(:is_identifier => true) }


  # Attributes
  
  attr_accessor :entity

  def settings
    self[:settings] ||= {}
  end

  def show_on_entity
    settings['show_on_entity']
  end

  def show_on_entity=(value)
    settings['show_on_entity'] = value
  end

  def human
    show_label.presence || name
  end
  
  
  # Dataset validation
  
  def validate_value
    
  end
  
  def add_error(error)
    message = "#{show_label} "
    message += case error
      when Symbol then I18n.t("activerecord.errors.messages.#{error}")
      when Strnig then error
      else
        raise "unknown dataset field error class '#{error.class.to_s}'"
    end
    
    entity.errors[:base] << message
  end
  
  
  # Utility
  
  def h
    ApplicationController.helpers
  end
  
  
  # Accessors
  
  def self.partial_name
    to_s.split('::').last.underscore
  end
  
  def self.show_partial_name
    "fields/show/#{partial_name}"
  end
  
  def self.form_partial_name
    "fields/form/#{partial_name}"
  end
  
  def self.search_partial_name
    "fields/search/#{partial_name}"
  end
  
  def self.merge_partial_name
    "fields/merge/#{partial_name}"
  end
  
  def self.config_form_partial_name
    "fields/config_form/#{partial_name}"
  end
  
  def self.label
    raise "please implement in subclass"
  end

  def form?
    true
  end
  
  def index?
    false
  end
  
  def value
    entity.dataset[name]
  end
  
  
  # Formats
  
  def serializable_hash(*args)
    super :methods => [:value], :root => false
  end
  
end
