class RemoveMongodb < ActiveRecord::Migration
  def up
    add_column :entities, :attachment, :text

    config = Rails.configuration.database_configuration[Rails.env]["mongo"].reverse_merge(
      'host' => '127.0.0.1',
      'port' => 27017
    )

    command = [
      "mongoexport",
      "-h #{config['host']}:#{config['port']}",
      "--db #{config['database']}",
      "--jsonArray",
      "--collection attachments"
    ].join(' ')
    
    data = JSON.parse(`#{command}`)

    data.each do |doc|
      entity = Entity.where(:id => doc["entity_id"]).first || 
        Entity.where(:attachment_id => doc['_id']['$oid']).first

      if entity
        doc.delete "_id"
        doc.delete "entity_id"
        new_value = entity.attachment
        new_value.merge! doc
        entity.update_column :attachment, JSON.dump(new_value)
      end
    end

    Entity.find_each do |entity|
      new_value = entity.attachment
      new_value["fields"] = if entity.external_references.present?
        YAML.load entity.external_references
      else
        {}
      end
      entity.update_column :attachment, JSON.dump(new_value)
    end

    remove_column :entities, :attachment_id
    remove_column :entities, :external_references
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
