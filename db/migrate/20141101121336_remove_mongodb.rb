class RemoveMongodb < ActiveRecord::Migration
  def up
    add_column :entities, :attachment, :text

    config = Rails.configuration.database_configuration[Rails.env]["mongo"].reverse_merge(
      'host' => '127.0.0.1',
      'port' => 27_017
    )

    command = [
      "mongoexport",
      "-h #{config['host']}:#{config['port']}",
      "--db #{config['database']}",
      "--jsonArray",
      "--collection attachments"
    ].join(' ')

    data = JSON.parse(`#{command}`)
    # data = JSON.parse(File.read "./attachments.json")

    puts "Iterating mongodb documents"
    counter = 0
    data.each do |doc|
      counter += 1
      puts "#{counter}/#{data.size}" if counter % 100 == 0

      entity = (
        Entity.where(id: doc["entity_id"]).first ||
        Entity.where(attachment_id: doc['_id']['$oid']).first
      )

      if entity
        doc.delete "_id"
        doc.delete "entity_id"
        new_value = entity.attachment
        new_value.merge! doc
        entity.update_column :attachment, new_value
      end
    end

    puts "Iterating entities"
    counter = 0
    Entity.find_each do |entity|
      counter += 1
      puts "#{counter}/#{data.size}" if counter % 100 == 0

      new_value = entity.attachment
      new_value["fields"] = if entity.external_references.present?
        yaml = entity.external_references
        result = YAML.load(yaml) || {}
        result.each do |k, _v|
          result[k].force_encoding("utf-8")
        end
        result
      else
        {}
      end

      if new_value["fields"]
        new_value["fields"].each do |_k, v|
          v.force_encoding("utf-8")
        end
      end

      entity.update_column :attachment, new_value
    end

    remove_column :entities, :attachment_id
    remove_column :entities, :external_references
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
