class AlterDatasetLiteratures < ActiveRecord::Migration
  def self.up
    change_column :dataset_literatures, :year_of_publication, :string
  end

  def self.down
    change_column :dataset_literatures, :year_of_publication, :integer
  end
end
