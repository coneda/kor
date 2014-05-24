class AddExternalReferencesToEntities < ActiveRecord::Migration
  def self.up
    add_column :entities, :external_references, :text
  end

  def self.down
    remove_column :entities, :external_references
  end
end
