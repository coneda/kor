class RemoveDatasetPeople < ActiveRecord::Migration
  def self.up
    people = Kind.find_by_name("Person")
    people.dataset_class = nil
    people.save
    
    puts "removing dataset from people"
    Entity.update_all "dataset_type = NULL, dataset_id = NULL", "kind_id = #{people.id}"
    
    drop_table :dataset_people
  end

  def self.down
    raise ActiveSupport::IrreversibleMigration
  end
end
