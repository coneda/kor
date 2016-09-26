class AddStorageToUsers < ActiveRecord::Migration
  def change
    add_column :users, :storage, :text
    drop_table :sessions
  end
end
