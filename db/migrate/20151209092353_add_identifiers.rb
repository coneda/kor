class AddIdentifiers < ActiveRecord::Migration
  def up
    create_table :identifiers do |t|
      t.string :entity_uuid
      t.string :kind
      t.string :value

      t.timestamps
    end

    add_index :identifiers, :entity_uuid
    add_index :identifiers, :value

    add_column :fields, :is_identifier, :boolean
  end

  def down
    remove_column :fields, :is_identifier
    drop_table :identifiers
  end
end
