class Collection < ApplicationRecord
  has_many :entities
  has_many :grants, :dependent => :destroy
  has_many :credentials, :through => :grants
  has_one :owner, :class_name => 'User', :foreign_key => :collection_id
  
  scope :personal, lambda { joins(:owner) }
  scope :non_personal, lambda {
    personal_ids = joins(:owner).select('collections.id').map{|c| c.id}
    personal_ids.empty? ? all : where("id NOT IN (?)", personal_ids)
  }

  validates :name,
    :presence => true,
    :uniqueness => true,
    :white_space => true  

  after_save :update_personals

  def update_personals
    if personal? && propagate && @grants_by_policy_buffer
      collections = self.class.joins(:owner).where("collections.id != ?", self.id)
      
      collections.each do |collection|
        params = {}
      
        @grants_by_policy_buffer.each do |policy, credential_ids|
          own_c_id = self.owner.credential_id.to_s
          other_c_id = collection.owner.credential_id.to_s
          
          if credential_ids.include? own_c_id
            params[policy] = credential_ids - [own_c_id] + [other_c_id]
          end
        end
        
        Collection.find(collection.id).update_attributes(:grants_by_policy => params, :propagate => false)
      end
    end
  end
  
  attr_writer :propagate

  def entity_count
    entities.count
  end
  
  def propagate
    @propagate = (@propagate == false ? false : true)
  end
  
  def personal?
    !!owner
  end
  
  def list_name
    name
  end

  def permissions
    {}.tap do |results|
      Kor::Auth.policies.each{|e| results[e] = []}
      grants.each do |grant|
        results[grant.policy] << grant.credential_id
      end
    end
  end

  def permissions=(values)
    grants.destroy_all

    values.each do |policy, credential_ids|
      credential_ids.each do |id|
        grants.find_or_create_by(policy: policy, credential_id: id)
      end
    end
  end
end
