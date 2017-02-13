class CreateRelationshipDatings < ActiveRecord::Migration
  def change
    create_table :relationship_datings do |t|
      t.integer :relationship_id
      t.string :label
      t.string :dating_string
      t.integer :from_day
      t.integer :to_day
      t.integer :lock_version
    end

    add_index :relationship_datings, :relationship_id, name: 'rely'
    add_index :relationship_datings, [:from_day, :to_day], name: 'timely'

    add_index :entity_datings, [:from_day, :to_day], name: 'timely'
  end
end
