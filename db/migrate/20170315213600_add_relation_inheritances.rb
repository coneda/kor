class AddRelationInheritances < ActiveRecord::Migration
  def change
    create_table :relation_inheritances, primary_key: false do |t|
      t.integer  :parent_id
      t.integer  :child_id

      t.timestamps
    end

    add_column :relations, :url, :string
    add_column :relations, :abstract, :boolean
  end
end
