class MergeArtworkMaterialAndTechnique < ActiveRecord::Migration
  def self.up
    change_table :dataset_artworks do |t|
      t.string :material_technique
    end

    Artwork.reset_column_information

    Artwork.all.each do |a|
      a.material_technique = "#{a.material}#{(a.material.blank? or a.technique.blank? ) ? "" : ', '}#{a.technique}"
    end

    change_table :dataset_artworks do |t|
      t.remove :material
      t.remove :technique
    end
  end

  def self.down
    raise IrreversibleMigration
  end
end
