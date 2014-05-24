class RenamePublishedToShared < ActiveRecord::Migration
  def self.up
    rename_column :user_groups, :published, :shared
  end

  def self.down
    rename_column :user_groups, :shared, :published
  end
end
