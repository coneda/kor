class AddMoreSettingsToUsers < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.integer :default_collection_id
      t.string :home_page
    end
  end

  def self.down
    change_table :users do |t|
      t.remove :default_collection_id
      t.remove :home_page
    end
  end
end
