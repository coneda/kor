class MakeAllEntitiesBelongToAMedium < ActiveRecord::Migration
  def self.up
    add_column :media, :state, :string
  
    add_column :entities, :medium_id, :integer
    
    rename_column :kinds, :mongo_profile, :schema_name
    rename_column :kinds, :dataset_class, :attachment_class
    rename_column :entities, :mongo_id, :attachment_id
    
    Entity.reset_column_information
    Medium.reset_column_information
    Kind.reset_column_information
    
    if artworks = Kind.find_by_attachment_class('Artwork')
      artworks.update_attributes :attachment_class => nil, :schema_name => 'artwork'
    end
    
    if literatures = Kind.find_by_attachment_class('Literature')
      literatures.update_attributes :attachment_class => nil, :schema_name => 'literature'
    end
    
    if textuals = Kind.find_by_attachment_class('Textual')
      textuals.update_attributes :attachment_class => nil, :schema_name => nil
    end
    
    if images = Kind.find_by_attachment_class('KorImage')
      images.update_attributes :attachment_class => nil, :schema_name => nil, :name => 'Medium'
    end
    
    query = "
      SELECT
        e.id as id,
        i.id as image_id,
        i.uri as uri,
        i.datahash as datahash
      FROM entities e
        LEFT JOIN dataset_images i ON e.dataset_id = i.id
      WHERE
        e.medium_id IS NULL
        AND e.dataset_type = 'KorImage'
    "
    counter = 0
    select_all(query).each do |row|
      puts counter if (counter += 1) % 100 == 0

      id = row['id']
      image_id = row['image_id']
      image_path = "#{Rails.root}/data/images/originals/#{image_id % 1000}/#{image_id}.image"
      unless File.exists? image_path
        puts "original #{image_id} does not exist at #{image_path}"
      else
        puts "working on original #{image_id}: #{image_path}"

        entity = Entity.find(row['id'])
        medium = Medium.create(:document => File.open(image_path))
        if medium.id
          Entity.connection.update("UPDATE entities SET medium_id = #{medium.id} WHERE id = #{id}")
        else
          puts "medium #{image_id} is invalid: #{medium.errors.full_messages.inspect}"
        end
      end
    end
    
    counter = 0
    Entity.find_each do |entity|
      puts counter if (counter += 1) % 100 == 0

      properties = Kor.db.select_all("SELECT entity_id, label, value FROM properties WHERE entity_id = #{entity.id}")
      synonyms = Kor.db.select_all("SELECT entity_id, name FROM synonyms WHERE entity_id = #{entity.id}")
      dataset = if !entity.dataset_type.blank? && entity.dataset_type != 'KorImage'
        table = case entity.dataset_type
        when 'Literature' then 'dataset_literatures'
        when 'Artwork' then 'dataset_artworks'
        when 'Textual' then 'dataset_textuals'
        else
          raise "unknown dataset class #{entity.dataset_type.inspect}"
        end
        
        d = Kor.db.select_all("SELECT * FROM #{table} WHERE id = #{entity.dataset_id}").first
        d.delete('id')
        d.delete('lock_version')
        d
      else
        {}
      end
      
      entity.properties = properties.map{|p| {'label' => p['label'], 'value' => p['value']}}
      entity.synonyms = synonyms.map{|s| s['name']}
      entity.dataset = dataset
      entity.save :validate => false
    end
    
    change_table :entities do |t|
      t.remove :dataset_id
      t.remove :dataset_type
    end
    
  end

  def self.down
    remove_column :media, :state
  
    rename_column :kinds, :schema_name, :mongo_profile
    rename_column :kinds, :attachment_class, :dataset_class
    rename_column :entities, :attachment_id, :mongo_id
    
    remove_column :entities, :medium_id
  end
end
