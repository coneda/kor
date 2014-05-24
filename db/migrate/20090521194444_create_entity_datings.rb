class CreateEntityDatings < ActiveRecord::Migration
  def self.up
    create_table :entity_datings do |t|
      t.integer :lock_version
      t.integer :entity_id
    
      t.string :label
      t.string :dating_string
      t.integer :from_day
      t.integer :to_day
    end

    EntityDating.reset_column_information
    
    Kind.find_each do |k|
      if k.name == "Person"
        k.set(:default_dating_label, I18n.t("datings.person", :count => 1))
      else
        k.set(:default_dating_label, I18n.t("datings.default", :count => 1))
      end
      k.save
    end
    
    puts "transfering the dating information into the new storage engine"
    puts "found #{Entity.count / 1000} batches"
    puts "this could take a few minutes"
    batch = 1
    
    Entity.find_in_batches(:include => :kind) do |set|
      print "starting batch #{batch} ... "
      set.each do |e|
        if e.dataset_id && e.dataset_type
          table_name = 'dataset_' + e.dataset_type.pluralize.underscore.split('_').last
          dataset = Kor.db.select_all("SELECT * FROM #{table_name} WHERE id = #{e.dataset_id}").first
        
          if dataset.keys.include?("dating_string")
            ds = e.datings.find_or_initialize_by_label_and_dating_string(
              e.kind.get(:default_dating_label),
              dataset['dating_string']
            )
            ds.save(false)
          end
          
          if dataset.keys.include?("life_data")
            ds = e.datings.find_or_initialize_by_label_and_dating_string(
              e.kind.get(:default_dating_label),
              dataset['life_data']
            )
            ds.save(false)
          end
        end
      end
      puts "done"
      batch += 1
    end
    
    Entity.group('dataset_type').count.each do |t, c|
      if t
        table_name = 'dataset_' + t.pluralize.underscore.split('_').last
        if Kor.db.columns(table_name).map{|c| c.name}.include? 'dating_string'
          remove_column table_name, :dating_string, :dating_from, :dating_to
        end
      end
    end
    
    remove_columns :dataset_people, :life_data, :dating_from, :dating_to
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
