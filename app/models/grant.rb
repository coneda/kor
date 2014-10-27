class Grant < ActiveRecord::Base
  
  self.table_name = 'collections_credentials'
  
  belongs_to :collection
  belongs_to :credential
  
  scope :with_policy, lambda { |name|
    name.blank? ? scoped : where(:policy => name)
  }
  
  def personal?
    !!credential.owner
  end

end  
