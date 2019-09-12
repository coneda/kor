require 'awesome_nested_set'

class AuthorityGroupCategory < ApplicationRecord
  acts_as_nested_set :dependent => :destroy

  has_many :authority_groups, :dependent => :destroy

  validates :name,
    :presence => true,
    :uniqueness => {:scope => :parent_id},
    :white_space => true
end
