class AddParentIdToUsers < ActiveRecord::Migration
  def up
    change_table :users do |t|
      t.string :parent_username
      t.index :parent_username
    end
  end

  def down
    change_table :users do |t|
      t.remove :parent_username
    end
  end
end
