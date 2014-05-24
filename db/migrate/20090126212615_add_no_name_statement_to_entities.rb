class AddNoNameStatementToEntities < ActiveRecord::Migration
  def self.up
    add_column :entities, :no_name_statement, :string
  end

  def self.down
    remove_column :entities, :no_name_statement
  end
end
