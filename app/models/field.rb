class Field < ActiveRecord::Base
  
  # ActiveRecord settings
  
  serialize :settings, Hash
  
  belongs_to :kind
  
  validates :name,
    :presence => true,
    :format => {:with => /\A[a-z0-9_]+\z/},
    :uniqueness => {:scope => :kind_id},
    :white_space => true
  validates :show_label, :form_label, :search_label, presence: true
  
  before_validation do |f|
    f.form_label = f.show_label if f.form_label.blank?
    f.search_label = f.show_label if f.search_label.blank?
    f.generate_uuid
  end

  after_create do |f|
    f.synchronize_identifiers :create
  end
  after_update do |f|
    f.synchronize_identifiers :update
    if name_changed?
      f.class.delay.synchronize_storage(f.kind_id, f.name_was, f.name)
    end
  end
  after_destroy do |f|
    f.class.delay.synchronize_storage(f.kind_id, f.name_was, nil)
    f.destroy_identifiers
  end

  def generate_uuid
    self.uuid ||= SecureRandom.uuid
  end

  def synchronize_identifiers(mode)
    if is_identifier_changed? || id_changed?
      others_changed = false

      self.class.where(name: self.name).each do |f|
        if f.is_identifier != self.is_identifier
          others_changed = true
          f.update_column :is_identifier, self.is_identifier
        end

        if is_identifier?
          if (mode == :update || others_changed)
            f.delay.create_identifiers
          end
        else
          Identifier.where(:kind => name).delete_all
        end
      end
    end
  end

  def create_identifiers
    kind_ids = self.class.where(name: self.name).map{|f| f.kind_id}
    Entity.where(kind_id: kind_ids).find_each batch_size: 100 do |entity|
      entity.update_identifiers
    end
  end

  def destroy_identifiers
    if self.class.where(name: name).where('id != ?', id).count == 0
      Identifier.where(kind: name).delete_all
    end
  end

  def self.synchronize_storage(kind_id, before, after)
    scope = Entity.where(kind_id: kind_id).select([:id, :attachment])
    scope.find_each batch_size: 100 do |e|
      if after
        e.dataset[after] = e.dataset[before]
      end
      e.dataset.delete(before)
      e.update_column :attachment, e.attachment
    end
  end

  scope :identifiers, lambda { where(:is_identifier => true) }


  # Attributes
  
  attr_accessor :entity

  def settings
    unless self[:settings]
      self[:settings] = {}
    end

    self[:settings]
  end

  def show_on_entity
    settings['show_on_entity']
  end

  def show_on_entity=(value)
    settings['show_on_entity'] = case value
      when "1" then true
      when "0" then false
      else
        !!value
    end
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

  def self.fields
    []
  end
  
  # TODO remove all of those once the kind/field/generator editor is complete
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
    if entity
      entity.dataset[name]
    end
  end
  
  
  # Formats
  
  def serializable_hash(*args)
    super(methods: [:value, :show_on_entity]).stringify_keys
  end
  
end
