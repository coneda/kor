class MakeKindsANestedSet < ActiveRecord::Migration
  def change
    add_column :kinds, :abstract, :boolean
    add_column :kinds, :url, :string

    add_column :kinds, :parent_id, :integer
    add_column :kinds, :lft, :integer
    add_column :kinds, :rgt, :integer
    add_column :kinds, :children_count, :integer, null: false, default: 0

    add_index :kinds, :rgt, name: 'right_index'
    add_index :kinds, [:parent_id, :lft, :rgt], name: 'list_index'
  end
end
