class RenamePersonDating < ActiveRecord::Migration
  def self.up
    rename_column :dataset_people, :dating_string, :life_data
  end

  def self.down
    rename_column :dataset_people, :life_data, :dating_string
  end
end
