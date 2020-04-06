class AddPositionToField < ActiveRecord::Migration
  def up
    unless column_exists?(:fields, :position)
      add_column :fields, :position, :integer

      Kind.all.each do |kind|
        kind.fields.each.with_index do |field, i|
          field.update_column :position, i
        end
      end
    end
  end

  def down
    remove_column :fields, :position
  end
end
