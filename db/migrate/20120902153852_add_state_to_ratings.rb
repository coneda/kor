class AddStateToRatings < ActiveRecord::Migration
  def up
    change_table :ratings do |t|
      t.string :state
    end
    
    add_index :ratings, [:entity_id, :state]
  end
  
  def down
    remove_index :ratings, [:entity_id, :state]
  
    change_table :ratings do |t|
      t.remove :state
    end
  end
end
