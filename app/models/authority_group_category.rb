class AuthorityGroupCategory < ActiveRecord::Base
  acts_as_nested_set :dependent => :destroy
  
  has_many :authority_groups, :dependent => :destroy
  
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :parent_id

  def serializable_hash(options = {})
    result = {:name => self.name}
    if parent
      result[:parent] = self.parent.serializable_hash(options)
    end
    result
  end
end
