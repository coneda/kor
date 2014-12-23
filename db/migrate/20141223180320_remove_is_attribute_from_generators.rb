class RemoveIsAttributeFromGenerators < ActiveRecord::Migration
  def up
    remove_column :generators, :is_attribute
  end

  def down
    add_column :generators, :is_attribute, :boolean
  end
end
