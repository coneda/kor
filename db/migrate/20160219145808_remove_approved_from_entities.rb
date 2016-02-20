class RemoveApprovedFromEntities < ActiveRecord::Migration
  def change
    remove_column :entities, :approved
  end
end
