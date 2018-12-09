class AuthorityGroup < EntityGroup
  has_and_belongs_to_many :entities
  belongs_to :authority_group_category

  if column_names.include? 'authority_group_category_id'
    validates :name, uniqueness: { scope: :authority_group_category_id }
  end
  
  default_scope lambda { order(name: 'asc') }
  
  scope :within_category, lambda { |id|
    id.present? ? 
      where(authority_group_category_id: id) :
      where(authority_group_category_id: nil)
  }
  scope :containing, lambda { |entity_ids|
    joins('JOIN authority_groups_entities ge on authority_groups.id = ge.authority_group_id').
      where('ge.entity_id' => entity_ids)
  }
end
