class Generator < ActiveRecord::Base
  
  # Associations
  
  belongs_to :kind
  
  
  # Validations
  
  validates_presence_of :name, :directive
  validates_format_of :name, :with => /^[a-z0-9_]+$/
  
  
  # Scopes
  
  scope :only_attributes, where(:is_attribute => true)
  
end
