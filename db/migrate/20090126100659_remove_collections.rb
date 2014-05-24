class RemoveCollections < ActiveRecord::Migration
  def self.up
    drop_table :collections
  end

  def self.down
    create_table :collections, :options => Kor.config['global_database_options'] do |t|
      t.string :name
      t.timestamps
    end
  end
end
