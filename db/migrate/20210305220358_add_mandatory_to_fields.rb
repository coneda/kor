class AddMandatoryToFields < ActiveRecord::Migration[5.0]
  def up
    add_column :fields, :mandatory, :boolean
  end

  def down
    remove_column :fields, :mandatory
  end
end
