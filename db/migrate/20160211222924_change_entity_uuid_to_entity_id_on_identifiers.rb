class ChangeEntityUuidToEntityIdOnIdentifiers < ActiveRecord::Migration
  def up
    add_column :identifiers, :entity_id, :integer

    Identifier.reset_column_information

    Identifier.all.each do |id|
      entity = Entity.select(:id).where(:uuid => id.entity_uuid).first
      if entity
        id.update_column :entity_id, entity.id
      end
    end

    remove_column :identifiers, :entity_uuid
  end

  def down
    add_column :identifiers, :entity_uuid, :string

    Identifier.reset_column_information

    Identifier.all.each do |id|
      entity = Entity.select(:uuid).where(:id => id.entity_id).first
      if entity
        id.update_column :entity_uuid, entity.uuid
      end
    end

    remove_column :identifiers, :entity_id
  end
end
