class AddSubtypeToEntities < ActiveRecord::Migration
  def self.up
    add_column :entities, :subtype, :string
    
    Entity.reset_column_information
    
    Entity.find_each do |e|
      if e.dataset_type && e.dataset_id
        table_name = 'dataset_' + e.dataset_type.pluralize.underscore.split('_').last
        dataset = Kor.db.select_all("SELECT * FROM #{table_name} WHERE id = #{e.dataset_id}").first
        Entity.update_all("subtype = '#{dataset['subtype']}'", "id = #{e.id}") if dataset['subtype']
      end
    end
    
    remove_column :dataset_artworks, :subtype
  end

  def self.down
    raise ActiveSupport::IrreversibleMigration
  end
end
