class AuthorityGroup < EntityGroup
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
  belongs_to :authority_group_category

  if column_names.include? 'authority_group_category_id'
    validates_uniqueness_of :name, :scope => :authority_group_category_id
  end
  
  default_scope lambda { order(:name => :asc) }
  
  scope :without_category, lambda { where(:authority_group_category_id => nil) }
  scope :containing, lambda {|entity_ids|
    joins('JOIN authority_groups_entities ge on authority_groups.id = ge.authority_group_id').
    where('ge.entity_id' => entity_ids)
  }

  def serializable_hash(options = {})
    options.merge! :root => false, :include => :authority_group_category
    super options
  end
end
