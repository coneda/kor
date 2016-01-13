class AddWikidataIds < ActiveRecord::Migration
  def up
    add_column :entities, :wikidata_id, :string
    add_column :kinds, :wikidata_id, :string
    add_column :relations, :wikidata_id, :string
    add_column :relationships, :wikidata_id, :string
    add_column :fields, :wikidata_id, :string
  end

  def down
    remove_column :entities, :wikidata_id
    remove_column :kinds, :wikidata_id
    remove_column :relations, :wikidata_id
    remove_column :relationships, :wikidata_id
    remove_column :fields, :wikidata_id
  end
end
