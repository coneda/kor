class Kor::EntityMerger

  def run(options = {})
    Entity.transaction do
      Relationship.transaction do
        process(options)
      end
    end
  end

  def process(options = {})
    if Entity.find(options[:old_ids].first).is_medium?
      options[:old_ids].reject!{|id| id == options[:attributes][:id]}
      entity = Entity.find(options[:attributes][:id])
      merge_externals options[:old_ids], entity.id
      merge_groups(options[:old_ids], entity.id)
    else
      entity = Entity.new(Entity.find(options[:old_ids]).first.attributes)
      entity.assign_attributes options[:attributes]
      entity.save :validate => false      
      merge_externals options[:old_ids], entity.id
    end
    
    Entity.destroy(options[:old_ids])
    entity
  end
  
  def merge_externals(old_ids, new_id)
    merge_relationships(old_ids, new_id)
    merge_entity_datings(old_ids, new_id)
  end
  
  def merge_relationships(old_ids, new_id)
    Relationship.update_all("from_id = #{new_id}", {:from_id => old_ids})
    Relationship.update_all("to_id = #{new_id}", {:to_id => old_ids})
  end
  
  def merge_entity_datings(old_ids, new_id)
    EntityDating.update_all("entity_id = #{new_id}", {:entity_id => old_ids})
  end
  
  def merge_groups(old_ids, new_id)
    groups = AuthorityGroup.find(:all,
      :select => 'authority_groups.*',
      :joins => 'JOIN authority_groups_entities et on authority_groups.id = et.authority_group_id',
      :conditions => {'et.entity_id' => old_ids}
    )
    
    groups += SystemGroup.find(:all,
      :select => 'system_groups.*',
      :joins => 'JOIN entities_system_groups et on system_groups.id = et.system_group_id',
      :conditions => {'et.entity_id' => old_ids}
    )
    
    groups += UserGroup.find(:all,
      :select => 'user_groups.*',
      :joins => 'JOIN entities_user_groups et on user_groups.id = et.user_group_id',
      :conditions => {'et.entity_id' => old_ids}
    )
    
    groups.each do |g|
      g.add_entities Entity.find(new_id)
    end
  end

end
