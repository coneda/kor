class RemoveSharedUserGroups < ActiveRecord::Migration
  def up
    change_table :user_groups do |t|
      t.remove :shared
    end
  end

  def down
    change_table :user_groups do |t|
      t.boolean :shared
    end
  end
end
