class AddUuidsToFields < ActiveRecord::Migration
  def up
    add_column :fields, :uuid, :string

    Field.reset_column_information

    Field.all.each do |field|
      field.update uuid: SecureRandom.uuid
    end
  end

  def down
    remove_column :fields, :uuid
  end
end
