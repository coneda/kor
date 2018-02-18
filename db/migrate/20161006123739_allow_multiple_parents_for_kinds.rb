class AllowMultipleParentsForKinds < ActiveRecord::Migration
  def up
    create_table :kind_inheritances, primary_key: false do |t|
      t.integer :parent_id
      t.integer :child_id

      t.timestamps
    end

    change_table :kinds do |t|
      t.remove :parent_id
      t.remove :lft
      t.remove :rgt
      t.remove :children_count
    end
  end
end