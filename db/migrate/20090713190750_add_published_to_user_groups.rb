class AddPublishedToUserGroups < ActiveRecord::Migration
  def self.up
    add_column :user_groups, :published, :boolean
  end

  def self.down
    remove_column :user_groups, :published
  end
end
