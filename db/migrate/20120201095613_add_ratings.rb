class AddRatings < ActiveRecord::Migration
  def up
    create_table :ratings do |t|
      t.string :namespace
    
      t.integer :user_id
      t.integer :entity_id
      
      t.text :data
      
      t.timestamps
    end
    
    add_column :users, :rating_admin, :boolean
  end

  def down
    remove_column :users, :rating_admin
    drop_table :ratings
  end
end
