class RenamePropertyName < ActiveRecord::Migration
  def self.up
    rename_column :properties, :name, :label
  end

  def self.down
    rename_column :properties, :label, :name
  end
end
