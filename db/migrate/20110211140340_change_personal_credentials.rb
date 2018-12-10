class ChangePersonalCredentials < ActiveRecord::Migration
  def self.up
    [:credentials, :users, :collections].each do |table|
      remove_index table, :parent_id

      change_table table do |t|
        t.remove :template
        t.remove :parent_id
      end
    end

    change_table :users do |t|
      t.integer :collection_id
      t.integer :credential_id
    end
  end

  def self.down
    change_table :users do |t|
      t.remove :collection_id
      t.remove :credential_id
    end

    [:credentials, :users, :collections].each do |table|
      change_table table do |t|
        t.boolean :template
        t.integer :parent_id
      end

      add_index table, :parent_id
    end
  end
end
