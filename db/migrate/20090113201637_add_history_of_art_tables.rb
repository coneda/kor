class AddHistoryOfArtTables < ActiveRecord::Migration
  def self.up
    create_table :dataset_artworks, options: Kor.config['global_database_options'] do |t|
      t.string :subtype
      t.string :dimensions
      t.string :material
      t.string :technique
      t.string :dating_string
      t.integer :dating_from
      t.integer :dating_to
    end

    create_table :dataset_people, options: Kor.config['global_database_options'] do |t|
      t.string :prename
      t.string :dating_string
      t.integer :dating_from
      t.integer :dating_to
    end

    create_table :dataset_literatures, options: Kor.config['global_database_options'] do |t|
      t.string :isbn
      t.integer :year_of_publication
      t.string :edition
      t.string :publisher
    end
  end

  def self.down
    Kind.get("artwork").destroy
    Kind.get("people").destroy
    Kind.get("literatures").destroy

    drop_table :dataset_artworks
    drop_table :dataset_people
    drop_table :dataset_literatures
  end
end
