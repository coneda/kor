class SystemGroup < EntityGroup
  has_and_belongs_to_many :entities do
    def only(kind)
      kind_id = Array(kind).collect{|k| k.is_a?(Kind) ? k.id : k }
      is_a(kind_id).alphabetically
    end
    
    def images
      only(Kind.medium_kind)
    end
    
    def without_images
      except(Kind.medium_kind)
    end
  end
  
  scope :containing, lambda {|entity_ids|
    joins('JOIN entities_system_groups ge on system_groups.id = ge.system_group_id').
    where('ge.entity_id' => entity_ids)
  }
end
