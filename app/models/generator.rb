class Generator < ActiveRecord::Base
  
  belongs_to :kind
  
  validates :name,
    :presence => true,
    :format => {:with => /^[a-z0-9_]+$/},
    :white_space => true

  validates :directive,
    :presence => true
  
  def human
    show_label.presence || name
  end
  
end
