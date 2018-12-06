class AddMedia < ActiveRecord::Migration
  def self.up
    create_table :media do |t|
      t.integer :lock_version
    
      t.string :image_file_name
      t.string :image_content_type
      t.integer :image_file_size
      t.integer :image_updated_at
    
      t.string :document_file_name
      t.string :document_content_type
      t.integer :document_file_size
      t.integer :document_updated_at
      
      t.string :datahash
      
      t.string :original_url
      t.boolean :cache
    end
  end
    
  def self.down
    drop_table :media
  end
end
