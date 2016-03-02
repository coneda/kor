class ChangeDescriptionsToText < ActiveRecord::Migration
  def change
    change_column :kinds, :description, :text
    change_column :relations, :description, :text
    change_column :credentials, :description, :text
  end
end
