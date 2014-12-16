class EntityGroup < ActiveRecord::Base
  self.abstract_class = true
  
  scope :named_like, lambda { |pattern| where("name LIKE ?", "%#{pattern}%") }

  validates :name,
    :presence => true,
    :white_space => true  

  def add_entities(new_entities)
    new_entities = [new_entities] unless new_entities.is_a? Array
    new_entities.reject{|e| self.entities.to_a.include? e}.each do |e|
      entities << e
    end
  end

  def remove_entities(old_entities)
    entities.delete(old_entities)
  end
  
  after_validation(:on => :create) do |model|
    model.uuid = UUIDTools::UUID.random_create.to_s
  end
end
