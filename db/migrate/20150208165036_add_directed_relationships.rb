class AddDirectedRelationships < ActiveRecord::Migration
  def up
    create_table :directed_relationships do |t|
      t.integer :relation_id
      t.boolean :reverse

      t.integer :from_id
      t.integer :to_id

      t.timestamps
    end

    add_index :directed_relationships, :relation_id
    add_index :directed_relationships, :from_id
    add_index :directed_relationships, :to_id
    add_index :directed_relationships, [:relation_id, :reverse, :from_id, :to_id], :name => :ally

    change_table :relationships do |t|
      t.integer :natural_id
      t.integer :reversal_id
    end

    Relationship.reset_column_information

    Relationship.find_each do |r|
      r.ensure_directed
    end
  end

  def down
    drop_table :directed_relationships

    change_table :relationships do |t|
      t.remove :natural_id
      t.remove :reversal_id
    end
  end
end
