class AddOptimisticLocking < ActiveRecord::Migration
  def self.up
    add_column :entities, :lock_version, :integer, :default => 0
    add_column :users, :lock_version, :integer, :default => 0
    add_column :kinds, :lock_version, :integer, :default => 0
    add_column :dataset_images, :lock_version, :integer, :default => 0
    add_column :dataset_artworks, :lock_version, :integer, :default => 0
    add_column :dataset_people, :lock_version, :integer, :default => 0
    add_column :dataset_literatures, :lock_version, :integer, :default => 0
    add_column :credentials, :lock_version, :integer, :default => 0
    add_column :tags, :lock_version, :integer, :default => 0
    add_column :synonyms, :lock_version, :integer, :default => 0
    add_column :properties, :lock_version, :integer, :default => 0
    add_column :relations, :lock_version, :integer, :default => 0
    add_column :relationships, :lock_version, :integer, :default => 0
  end

  def self.down
    remove_column :entities, :lock_version
    remove_column :users, :lock_version
    remove_column :kinds, :lock_version
    remove_column :dataset_images, :lock_version
    remove_column :dataset_artworks, :lock_version
    remove_column :dataset_people, :lock_version
    remove_column :dataset_literatures, :lock_version
    remove_column :credentials, :lock_version
    remove_column :tags, :lock_version
    remove_column :synonyms, :lock_version
    remove_column :properties, :lock_version
    remove_column :relations, :lock_version
    remove_column :relationships, :lock_version
  end
end
