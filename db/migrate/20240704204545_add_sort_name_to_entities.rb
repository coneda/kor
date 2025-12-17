class AddSortNameToEntities < ActiveRecord::Migration[7.0]
  def up
    change_table :entities do |t|
      t.string :sort_name
    end

    Entity.reset_column_information

    attrs = [
      :id, :distinct_name, :kind_id, :medium_id, :no_name_statement, :name
    ]
    Entity.select(*attrs).find_each do |entity|
      sort_name = entity.generate_sort_name
      next if sort_name.blank?

      entity.update_column :sort_name, sort_name
    end
  end

  def down
    change_table :entities do |t|
      t.remove :sort_name
    end
  end
end
