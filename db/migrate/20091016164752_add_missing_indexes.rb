class AddMissingIndexes < ActiveRecord::Migration
  def self.up
    add_index :relations, :reverse_name
    add_index :user_groups, :shared
    
    # join indexes
    add_index :authority_groups, :authority_group_category_id
    add_index :publishments, :user_id
    add_index :entity_datings, :entity_id
    
    # join table indexes
    add_index :credentials_users, :user_id
    add_index :credentials_users, :credential_id
    add_index :authority_groups_entities, :entity_id
    add_index :authority_groups_entities, :authority_group_id
    add_index :entities_system_groups, :entity_id
    add_index :entities_system_groups, :system_group_id
    add_index :entities_user_groups, :entity_id
    add_index :entities_user_groups, :user_group_id
    
    # redundant join table indexes
    remove_index :authority_groups_entities, :name => :ag_link_index
    remove_index :entities_system_groups, :name => :sg_link_index
    remove_index :entities_user_groups, :name => :ug_link_index
  end

  def self.down
    remove_index :relations, :reverse_name
    remove_index :user_groups, :shared
    
    # join indexes
    remove_index :authority_groups, :authority_group_category_id
    remove_index :publishments, :user_id
    remove_index :entity_datings, :entity_id
    
    # join table indexes
    remove_index :credentials_users, :user_id
    remove_index :credentials_users, :credential_id
    remove_index :authority_groups_entities, :entity_id
    remove_index :authority_groups_entities, :authority_group_id
    remove_index :entities_system_groups, :entity_id
    remove_index :entities_system_groups, :system_group_id
    remove_index :entities_user_groups, :entity_id
    remove_index :entities_user_groups, :user_group_id
    
    # redundant join table indexes 
    add_index :entities_system_groups, [:entity_id, :system_group_id], :unique => true, :name => 'sg_link_index'
    add_index :authority_groups_entities, [:entity_id, :authority_group_id], :unique => true, :name => 'ag_link_index'
    add_index :entities_user_groups, [:entity_id, :user_group_id], :unique => true, :name => 'ug_link_index'
  end
end
