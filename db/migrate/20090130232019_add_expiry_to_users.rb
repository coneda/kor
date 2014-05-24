class AddExpiryToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :expires_at, :timestamp
  end

  def self.down
    remove_column :users, :expires_at
  end
end
