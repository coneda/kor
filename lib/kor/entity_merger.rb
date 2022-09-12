class Kor::EntityMerger
  def run(options = {})
    ApplicationRecord.transaction do
      process(options)
    end
  rescue ActiveRecord::RecordInvalid
    @entity
  end

  def process(options = {})
    @entity = nil

    @entity = Entity.new(Entity.find(options[:old_ids]).first.attributes)
    @entity.id = nil
    @datings_attributes = options[:attributes].delete(:datings_attributes)
    @entity.assign_attributes options[:attributes]

    # delete the entities but keep their datings and relationships
    Entity.where(id: options[:old_ids]).map do |e|
      e.identifiers.delete_all
      e.delete
      e
    end
    @entity.save!
    # TODO: make sure this fails if there is no @entity.id

    merge_externals options[:old_ids], @entity.id
    @entity
  end

  def merge_externals(old_ids, new_id)
    merge_relationships(old_ids, new_id)
    merge_entity_datings(old_ids, new_id)
  end

  def merge_relationships(old_ids, new_id)
    Relationship.where(:from_id => old_ids).update_all(["from_id = ?", new_id])
    Relationship.where(:to_id => old_ids).update_all(["to_id = ?", new_id])
    DirectedRelationship.where(:from_id => old_ids).update_all(["from_id = ?", new_id])
    DirectedRelationship.where(:to_id => old_ids).update_all(["to_id = ?", new_id])
  end

  def merge_entity_datings(old_ids, new_id)
    EntityDating.where(:entity_id => old_ids).update_all(["entity_id = ?", new_id])

    if @datings_attributes
      # now that the existing datings have been transferred to the new (persisted)
      # entity, we can assign the datings from the merger widget
      @entity.reload.update! datings_attributes: @datings_attributes
    end
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
