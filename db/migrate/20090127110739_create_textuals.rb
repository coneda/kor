class CreateTextuals < ActiveRecord::Migration
  def self.up
    create_table :dataset_textuals, options: Kor.config['global_database_options'] do |t|
      t.integer :lock_version
      t.text :text
    end
  end

  def self.down
    drop_table :dataset_textuals
  end
end
