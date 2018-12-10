class AddDownloads < ActiveRecord::Migration
  def self.up
    create_table :downloads do |t|
      t.integer :user_id

      t.string :uuid
      t.string :file_name
      t.string :content_type

      t.timestamps
    end

    add_index :downloads, :uuid
  end

  def self.down
    drop_table :downloads
  end
end
