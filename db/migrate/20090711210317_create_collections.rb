class CreateCollections < ActiveRecord::Migration
  def self.up
    create_table :collections do |t|
      t.integer :lock_version
      t.string :name

      t.timestamps
    end

    # apparently, this column already exists from earlier migrations
    # add_column :entities, :collection_id, :integer
  end

  def self.down
    drop_table :collections
    # remove_column :entities, :collection_id
  end
end
