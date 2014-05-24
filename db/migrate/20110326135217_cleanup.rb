class Cleanup < ActiveRecord::Migration
  def self.up
    drop_table :searches
    drop_table :synonyms
    drop_table :properties
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
