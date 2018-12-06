class CreateAuthorityGroupCategories < ActiveRecord::Migration
  def self.up
    create_table :authority_group_categories do |t|
      t.integer :lock_version
      t.integer :parent_id
      t.integer :lft
      t.integer :rgt
      t.string :name

      t.timestamps
    end
    add_index :authority_group_categories, [:parent_id, :lft, :rgt], :unique => true, :name => 'agc_hierarchy_index'
    
    add_column :authority_groups, :authority_group_category_id, :integer
  end

  def self.down
    drop_table :authority_group_categories
    remove_colum :authority_groups, :authority_group_category_id
  end
end
