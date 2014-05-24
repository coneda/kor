class AddRequestDataToExceptionLogs < ActiveRecord::Migration
  def self.up
    change_table :exception_logs do |t|
      t.string :uri
      t.text :params
    end
  end

  def self.down
    change_table :exception_logs do |t|
      t.remove_column :uri
      t.remove_column :params
    end
  end
end
