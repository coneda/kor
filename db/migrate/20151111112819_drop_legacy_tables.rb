class DropLegacyTables < ActiveRecord::Migration
  def up
    drop_table :dataset_artworks
    drop_table :dataset_literatures
    drop_table :dataset_images
    drop_table :dataset_textuals

    drop_table :properties
    drop_table :searches
    drop_table :settings

    drop_table :engagements
    drop_table :ratings
    drop_table :synonyms

    Grant.where(:policy => "admin_rating").delete_all
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
