class AddSortNameToEntities < ActiveRecord::Migration[7.0]
  def up
    change_table :entities do |t|
      t.string :sort_name
    end

    Entity.reset_column_information

    Entity.find_each do |entity|
      entity.update_column :sort_name, entity.generate_sort_name
    end
  end

  def down
    change_table :entities do |t|
      t.remove :sort_name
    end
  end
end
