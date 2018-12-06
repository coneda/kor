class RefactorGroups < ActiveRecord::Migration
  def self.up
    create_table :system_groups do |t|
      t.integer :lock_version
      t.string :name
      t.string :uuid
      
      t.timestamps
    end
    create_table :entities_system_groups, :id => false do |t|
      t.integer :entity_id
      t.integer :system_group_id
    end
    add_index :entities_system_groups, [:entity_id, :system_group_id], :unique => true, :name => 'sg_link_index'
    
    create_table :authority_groups do |t|
      t.integer :lock_version
      t.string :name
      t.string :uuid
      
      t.timestamps
    end
    create_table :authority_groups_entities, :id => false do |t|
      t.integer :entity_id
      t.integer :authority_group_id
    end
    add_index :authority_groups_entities, [:entity_id, :authority_group_id], :unique => true, :name => 'ag_link_index'
    
    create_table :user_groups do |t|
      t.integer :lock_version
      t.integer :user_id      
      t.string :name
      t.string :uuid
      
      t.timestamps
    end
    create_table :entities_user_groups, :id => false do |t|
      t.integer :entity_id
      t.integer :user_group_id
    end
    add_index :user_groups, :user_id
    add_index :entities_user_groups, [:entity_id, :user_group_id], :unique => true, :name => 'ug_link_index'
  
    SystemGroup.reset_column_information
    AuthorityGroup.reset_column_information
    UserGroup.reset_column_information

    puts "retrieving tags with entities"
    count = Kor.db.select_all("SELECT count(*) as c FROM tags").first['c']
    counter = 1
    tag_ids = Kor.db.select_all("SELECT * from tags").each do |tag|
      puts "migrating tag #{tag['name']} (#{counter} out of #{count})"
      counter += 1
      
      attributes = {
        :name => tag['name'],
        :created_at => tag['created_at'],
        :updated_at => tag['updated_at'],
        :uuid => tag['uuid']
      }
      
      group = case tag['style']
      when "systemgroup"
        AuthorityGroup.create(attributes)
      when 'usergroup', "transit"
        attributes[:user_id] = tag['user_id']
        UserGroup.create(attributes)
      when "technical"
        SystemGroup.create(attributes)
      else
        raise "unknown tag/group style #{tag['style'].inspect}"
      end
      
      values = Kor.db.select_all("SELECT entity_id FROM entities_tags WHERE tag_id = #{tag['id']}").map do |m|
        "(#{m['entity_id']},#{tag['id']})"
      end.join(',')
      
      unless values.blank?
        case group
        when AuthorityGroup
          Kor.db.execute("INSERT INTO authority_groups_entities (entity_id, authority_group_id) VALUES #{values}")
        when UserGroup
          Kor.db.execute("INSERT INTO entities_user_groups (entity_id, user_group_id) VALUES #{values}")
        when SystemGroup
          Kor.db.execute("INSERT INTO entities_system_groups (entity_id, system_group_id) VALUES #{values}")
        end
      end
    end
  
    drop_table :tags, :entities_tags
  end

  def self.down
    drop_table :system_groups
    drop_table :authority_groups
    drop_table :user_groups
    drop_table :entities_system_groups
    drop_table :authority_groups_entities
    drop_table :entities_user_groups
  end
end
