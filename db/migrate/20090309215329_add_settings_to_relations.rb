class AddSettingsToRelations < ActiveRecord::Migration
  def self.up
    add_column :relations, :from_kind_ids, :text
    add_column :relations, :to_kind_ids, :text
  end

  def self.down
    remove_column :relations, :from_kind_ids
    remove_column :relations, :to_kind_ids
  end
end
