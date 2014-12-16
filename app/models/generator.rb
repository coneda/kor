class Generator < ActiveRecord::Base
  
  # Associations
  
  belongs_to :kind
  
  
  # Validations
  
  validates :name,
    :presence => true,
    :format => {:with => /^[a-z0-9_]+$/},
    :white_space => true
  validates :directive,
    :presence => true
  
  
  # Scopes
  
  scope :only_attributes, where(:is_attribute => true)

  def human
    show_label.presence || name
  end
  
end
