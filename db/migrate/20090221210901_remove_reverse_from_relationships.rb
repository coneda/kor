class RemoveReverseFromRelationships < ActiveRecord::Migration
  def self.up
    remove_column :relationships, :reverse
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
