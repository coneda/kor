class AddDescriptionToRelations < ActiveRecord::Migration
  def self.up
    add_column :relations, :description, :string
  end

  def self.down
    remove_column :relations, :description
  end
end
