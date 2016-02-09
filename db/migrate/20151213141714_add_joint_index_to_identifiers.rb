class AddJointIndexToIdentifiers < ActiveRecord::Migration
  def change
    add_index :identifiers, [:value, :kind]
  end
end
