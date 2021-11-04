class Field < ApplicationRecord
  serialize :settings, Hash

  acts_as_list scope: [:kind_id], top_of_list: 0
  default_scope{ order(:position) }
  
  belongs_to :kind, touch: true, optional: true

  validates :name,
    :presence => true,
    :format => {:with => /\A[a-z0-9_]+\z/, allow_blank: true},
    :uniqueness => {:scope => :kind_id},
    :white_space => true
  validates :show_label, :form_label, :search_label, presence: true

  validate do |f|
    if !f.new_record? && f.type_changed?
      f.errors.add :type, :cannot_be_changed
    end
  end

  before_validation do |f|
    f.form_label = f.show_label if f.form_label.blank?
    f.search_label = f.show_label if f.search_label.blank?
    f.type ||= 'Fields::String'
    f.generate_uuid
  end

  after_create do |f|
    f.synchronize_identifiers :create
  end
  after_update do |f|
    f.synchronize_identifiers :update
    if saved_change_to_name?
      GenericJob.perform_later(
        'constant', f.class.name,
        'synchronize_storage', f.kind_id, f.name_before_last_save, f.name
      )
    end
  end
  after_destroy do |f|
    GenericJob.perform_later(
      'constant', f.class.name,
      'synchronize_storage', f.kind_id, f.name_was, nil
    )
    f.destroy_identifiers
  end

  def generate_uuid
    self.uuid ||= SecureRandom.uuid
  end

  def synchronize_identifiers(mode)
    if saved_change_to_is_identifier? || saved_change_to_id?
      others_changed = false

      self.class.where(name: self.name).each do |f|
        if f.is_identifier != self.is_identifier
          others_changed = true
          f.update_column :is_identifier, self.is_identifier
        end

        if is_identifier?
          if (mode == :update || others_changed)
            GenericJob.perform_later 'object', self.class.name, f.id, 'create_identifiers'
          end
        else
          Identifier.where(:kind => name).delete_all
        end
      end
    end
  end

  def create_identifiers
    kind_ids = self.class.where(name: self.name).map{ |f| f.kind_id }
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

  scope :identifiers, lambda{ where(:is_identifier => true) }

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

  def help_text
    settings['help_text']
  end

  def help_text=(value)
    if value.present?
      settings['help_text'] = value
    else
      settings.delete('help_text')
      nil
    end
  end

  def help_text_html
    return nil if help_text.blank?

    RedCloth.new(help_text).to_html
  end

  def human
    show_label.presence || name
  end

  def validate_value
    if mandatory?
      return :empty if value.blank?
    end

    true
  end

  def self.fields
    []
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

  def serializable_hash(*args)
    super(methods: [:value, :show_on_entity]).stringify_keys
  end
end
