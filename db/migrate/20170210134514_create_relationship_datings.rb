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
  end
end
