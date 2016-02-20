class AddDirectedRelationships < ActiveRecord::Migration
  def up
    create_table :directed_relationships do |t|
      t.integer :relation_id
      t.integer :relationship_id

      t.boolean :is_reverse
      t.string :relation_name

      t.integer :from_id
      t.integer :to_id

      t.timestamps
    end

    change_table :relationships do |t|
      t.integer :normal_id
      t.integer :reversal_id
    end

    Relationship.reset_column_information

    ActiveRecord::Base.record_timestamps = false
    Relationship.includes(:relation).find_each do |r|
      r.ensure_directed
      r.normal.save
      r.reversal.save
    end
    ActiveRecord::Base.record_timestamps = true

    add_index :directed_relationships, :relation_id
    add_index :directed_relationships, :from_id
    add_index :directed_relationships, :to_id
    add_index :directed_relationships, [
      :relation_id, :is_reverse, :from_id, :to_id
    ], :name => :ally
  end

  def down
    drop_table :directed_relationships

    change_table :relationships do |t|
      t.remove :normal_id
      t.remove :reversal_id
    end
  end
end
