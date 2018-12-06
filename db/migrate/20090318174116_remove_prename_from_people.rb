class RemovePrenameFromPeople < ActiveRecord::Migration
  def self.up
    people = Kind.find_by_name('Person')
    if people
      people.entities.each do |e|
        e.name += ", " + e.dataset.prename
        unless e.save
          e.save(false)
          Tag.invalid_tag.add_entities(e)
        end
      end
    end

    remove_column :dataset_people, :prename
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
  
end
