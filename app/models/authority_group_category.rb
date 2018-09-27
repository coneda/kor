require 'awesome_nested_set'

class AuthorityGroupCategory < ActiveRecord::Base
  acts_as_nested_set :dependent => :destroy
  
  has_many :authority_groups, :dependent => :destroy

  validates :name,
    :presence => true,
    :uniqueness => {:scope => :parent_id},
    :white_space => true

  # default_scope lambda{order(name: 'asc')}

  def serializable_hash(options = {})
    result = {:name => self.name}
    if parent
      result[:parent] = self.parent.serializable_hash(options)
    end
    result
  end
end
