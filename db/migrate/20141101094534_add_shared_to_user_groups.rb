class AddSharedToUserGroups < ActiveRecord::Migration
  def change
    add_column :user_groups, :shared, :boolean
    add_index :user_groups, :shared, name: "shary"
  end
end
