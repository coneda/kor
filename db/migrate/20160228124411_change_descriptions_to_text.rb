class ChangeDescriptionsToText < ActiveRecord::Migration
  def change
    change_column :kinds, :description, :text, default: nil
    change_column :relations, :description, :text, default: nil
    change_column :credentials, :description, :text, default: nil
  end
end
