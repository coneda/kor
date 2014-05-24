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
  
  validates_uniqueness_of :name
end
