class AddTableSearches < ActiveRecord::Migration
  def self.up
    create_table :searches do |t|
      t.integer :user_id
      t.string :search_type

      t.integer :collection_id
      t.integer :kind_id
      
      t.string :name
      t.string :dating
      t.string :properties
      t.text :dataset
      
      t.text :relationships
      
      t.timestamps
    end
  
  end

  def self.down
    drop_table :searches
  end
end
