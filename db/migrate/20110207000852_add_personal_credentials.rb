class AddPersonalCredentials < ActiveRecord::Migration
  def self.up
    [:credentials, :users, :collections].each do |table|
      change_table table do |t|
        t.boolean :template
        t.integer :parent_id
      end
      
      add_index table, :parent_id
    end
    
    create_table :collections_credentials do |t|
      t.integer :collection_id
      t.integer :credential_id
      t.string :policy
    end
    
    add_index :collections_credentials, [:collection_id, :credential_id, :policy], :name => :master
    
    Collection.all.each do |collection|
      (collection.policy_groups || {}).each do |policy, credential_ids|
        credential_ids.each do |credential_id|
          Grant.create(
            :collection_id => collection.id,
            :policy => policy,
            :credential_id => credential_id
          )
        end
      end
    end
    
    remove_index :credentials, :name => :index_credentials_on_name
    add_index :credentials, :name
    
    remove_column :collections, :policy_groups
  end

  def self.down
    add_column :collections, :policy_groups, :text
  
    remove_index :credentials, :name => :index_credentials_on_name
    add_index :credentials, :name, :name => :index_credentials_on_name, :unique => true
  
    remove_index :collections_credentials, :name => :master
    drop_table :collections_credentials
  
    [:credentials, :users, :collections].each do |table|
      remove_index table, :parent_id
  
      change_table table do |t|
        t.remove :template
        t.remove :parent_id
      end
    end
  end
end
