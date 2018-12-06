class AddCollectionBasedSecurityToKor < ActiveRecord::Migration
  def self.up
    remove_column :entities, :reference_id
    remove_column :relationships, :reference_id
    
    change_table :collections do |t|
      t.text :policy_groups
    end

    change_table :users do |t|
      t.boolean :relation_admin
      t.boolean :authority_group_admin
      t.boolean :user_admin
      t.boolean :collection_admin
      t.boolean :kind_admin
      t.boolean :developer
      t.boolean :credential_admin
      t.boolean :admin
    end
    
    add_column :entities, :approved, :boolean
     

    Entity.reset_column_information
    Collection.reset_column_information
    User.reset_column_information
    
    c = Collection.find_by_name('default') || begin    
      execute "INSERT INTO collections (name) VALUES ('default')"
      Collection.find_by_name('default')
    end
    execute "UPDATE entities SET collection_id=#{c.id} WHERE collection_id IS NULL"
    execute "UPDATE entities SET approved=0"
    
    User.all.each do |user|
      credentials = user.groups.map { |c| c.name }
      
      if credentials.include? "admins"
        user.groups = [Credential.find_by_name('admins')]
        user.admin = true
        user.credential_admin = true
        user.authority_group_admin = true
        user.collection_admin = true
        user.kind_admin = true
        user.relation_admin = true
        user.user_admin = true
        user.developer = true
      elsif credentials.include? "maintainers"
        user.groups = [Credential.find_by_name('maintainers')]
        user.authority_group_admin = true
      elsif credentials.include? "editors"
        user.groups = [Credential.find_by_name('editors')]
        user.authority_group_admin = true
      elsif credentials.include? "users"
        user.groups = [Credential.find_by_name('users')]
      else
        
      end
      
      unless user.save
        puts user.errors.full_messages.inspect
        raise "validation error"
      end
    end
  end

  def self.down
    add_column :entities, :reference_id, :integer
    add_column :relationships, :reference_id, :integer
    
    change_table :collections do |t|
      t.remove :view_groups
      t.remove :edit_groups
      t.remove :maintain_groups
    end

    remove_column :entities, :approved
  end
end
