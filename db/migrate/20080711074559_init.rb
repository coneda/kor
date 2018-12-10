class Init < ActiveRecord::Migration
  def self.up
    ########################################## users ###########################

    create_table :users, :options => Kor.config['global_database_options'] do |t|
      t.string :full_name
      t.string :name
      t.string :email
      t.datetime :last_login

      t.boolean :active, :default => true
      t.string :password
      t.string :activation_hash

      t.string :locale

      t.timestamps
    end
    add_index :users, :name, :unique => true

    create_table :credentials, :options => Kor.config['global_database_options'] do |t|
      t.string :name
      t.string :description, :default => ""
    end
    add_index :credentials, :name, :unique => true

    create_table :credentials_users, :options => Kor.config['global_database_options'], :id => false do |t|
      t.integer :user_id
      t.integer :credential_id
    end
    add_index :credentials_users, [:user_id, :credential_id], :unique => true

    ####################################### entities ###########################

    create_table :entities, :options => Kor.config['global_database_options'] do |t|
      t.string :uuid
      t.string :name
      t.string :distinct_name
      t.text :comment

      t.integer :kind_id
      t.integer :reference_id
      t.integer :collection_id
      t.integer :dataset_id
      t.string :dataset_type
      t.integer :user_id

      t.timestamps
    end
    add_index :entities, :uuid
    add_index :entities, :name
    add_index :entities, :kind_id
    add_index :entities, :dataset_id
    add_index :entities, :dataset_type
    add_index :entities, :user_id
    # add_index :entities, [ :name, :display_name, :kind_id ], :unique => true
    add_index :entities, :distinct_name

    create_table :synonyms, :options => Kor.config['global_database_options'] do |t|
      t.integer :entity_id
      t.string :name
    end
    add_index :synonyms, :entity_id
    add_index :synonyms, :name

    create_table :kinds, :options => Kor.config['global_database_options'] do |t|
      t.string :uuid
      t.string :name
      t.string :description
      t.string :dataset_class
      t.text :settings

      t.timestamps
    end

    create_table :properties, :options => Kor.config['global_database_options'] do |t|
      t.integer :entity_id
      t.integer :reference_id
      t.string :name
      t.string :value

      t.timestamps
    end
    add_index :properties, :entity_id
    add_index :properties, :name
    add_index :properties, :value
    # add_index :properties, [ :entity_id, :name, :value ], :unique => true

    ####################################### relations ##########################

    create_table :relations, :options => Kor.config['global_database_options'] do |t|
      t.string :uuid
      t.string :name
      t.string :reverse_name

      t.timestamps
    end
    add_index :relations, :name

    create_table :relationships, :options => Kor.config['global_database_options'] do |t|
      t.string :uuid
      t.integer :reference_id
      t.integer :owner_id
      t.boolean :reverse
      t.integer :relation_id
      t.integer :from_id
      t.integer :to_id
      t.text :properties
      t.timestamps
    end
    add_index :relationships, [:relation_id, :from_id, :to_id]
    add_index :relationships, :uuid
    add_index :relationships, :relation_id
    add_index :relationships, :from_id
    add_index :relationships, :to_id

    ####################################### tagging ############################

    create_table :collections, :options => Kor.config['global_database_options'] do |t|
      t.string :name

      t.timestamps
    end

    create_table :tags, :options => Kor.config['global_database_options'] do |t|
      t.string :style
      t.string :uuid
      t.string :name
      t.integer :user_id

      t.timestamps
    end
    add_index :tags, :uuid
    add_index :tags, :name
    add_index :tags, :style
    add_index :tags, :user_id

    create_table :entities_tags, :options => Kor.config['global_database_options'], :id => false do |t|
      t.integer :entity_id
      t.integer :tag_id
    end
    add_index :entities_tags, [:entity_id, :tag_id], :unique => true

    create_table :publishments, :options => Kor.config['global_database_options'] do |t|
      t.integer :user_id
      t.integer :tag_id
      t.string :uuid
      t.string :name

      t.timestamp :valid_until
    end

    ####################################### media ##############################

    create_table :dataset_images, :options => Kor.config['global_database_options'] do |t|
      t.string  :uri
      t.string  :datahash
      t.string  :file_format
      t.integer :width
      t.integer :height
      t.integer :bytes
    end
  end

  def self.down
    # not needed .. its the first migration
  end
end
