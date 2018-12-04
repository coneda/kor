class Generator < ActiveRecord::Base
  belongs_to :kind, touch: true
  
  validates :name,
    :presence => true,
    :format => {:with => /\A[a-z0-9_]+\z/},
    :white_space => true

  validates :directive, :presence => true
end
