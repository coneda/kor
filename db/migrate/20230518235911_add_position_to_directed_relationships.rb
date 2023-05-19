class AddPositionToDirectedRelationships < ActiveRecord::Migration[7.0]
  def change
    change_table :directed_relationships do |t|
      t.integer :position, default: 0
    end
  end
end
