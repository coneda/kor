class AddMoreIndexes < ActiveRecord::Migration
  def change
    add_index :entities, [:kind_id, :deleted_at], name: 'typey'
  end
end
