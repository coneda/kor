class AddIndexForEntitiesCreatedAt < ActiveRecord::Migration
  def self.up
    add_index :entities, :created_at
  end

  def self.down
    remove_index :entities, :created_at
  end
end
