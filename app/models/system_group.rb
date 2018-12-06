class SystemGroup < EntityGroup
  has_and_belongs_to_many :entities
  
  scope :containing, lambda { |entity_ids|
    joins('JOIN entities_system_groups ge on system_groups.id = ge.system_group_id').
      where('ge.entity_id' => entity_ids)
  }
end
