class RemoveMongodb < ActiveRecord::Migration
  def up
    # add_column :entities, :attachment, :text
    # remove_column :entities, :attachment_id

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

    debugger

    raise "not actually doing it"
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
