class SynchronizeMediumKindUuid < ActiveRecord::Migration
  def up
    kind = Kind.find_by(name: ['medium', 'Medium'])
    if kind.uuid != Kind::MEDIA_UUID
      kind.update_column :uuid, Kind::MEDIA_UUID
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
