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
      entity.id = nil
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
    Relationship.where(:from_id => old_ids).update_all(:from_id => new_id)
    Relationship.where(:to_id => old_ids).update_all(:to_id => new_id)
  end
  
  def merge_entity_datings(old_ids, new_id)
    EntityDating.where(:entity_id => old_ids).update_all(:entity_id => new_id)
  end
  
  def merge_groups(old_ids, new_id)
    groups = (
      AuthorityGroup.containing(old_ids).to_a +
      SystemGroup.containing(old_ids).to_a +
      UserGroup.containing(old_ids).to_a
    )
    
    groups.each do |g|
      g.add_entities Entity.find(new_id)
    end
  end

end
