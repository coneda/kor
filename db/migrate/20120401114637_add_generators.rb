class AddGenerators < ActiveRecord::Migration
  def self.up
    create_table :generators do |t|
      t.integer :kind_id

      t.boolean :is_attribute

      t.string :name
      t.string :show_label
      t.text :directive

      t.timestamps
    end
  end

  def self.down
    drop_table :generators
  end
end
