class AddSchemaToKindsAndRelations < ActiveRecord::Migration
  def change
    add_column :kinds, :schema, :string
    add_column :relations, :schema, :string
  end
end
