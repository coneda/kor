class AddMongoProfileToKinds < ActiveRecord::Migration
  def self.up
    add_column :kinds, :mongo_profile, :string
    add_column :entities, :mongo_id, :string
  end

  def self.down
    remove_column :kinds, :mongo_profile
    remove_column :entities, :mongo_id
  end
end
