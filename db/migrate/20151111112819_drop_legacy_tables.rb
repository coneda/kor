class DropLegacyTables < ActiveRecord::Migration
  def up
    tables = [
      :dataset_literatures,
      :dataset_images,
      :dataset_textuals,
      :dataset_artworks,
      :properties,
      :searches,
      :settings,
      :engagements,
      :ratings,
      :synonyms
    ]

    tables.each do |table|
      if ActiveRecord::Base.connection.table_exists?(table)
        drop_table table
      end
    end

    Grant.where(policy: "admin_rating").delete_all
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
