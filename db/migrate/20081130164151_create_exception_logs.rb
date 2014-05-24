class CreateExceptionLogs < ActiveRecord::Migration
  def self.up
    create_table :exception_logs, :options => Kor.config['global_database_options'] do |t|
      t.string :kind
      t.string :message
      t.text :backtrace

      t.timestamp :created_at
    end
  end

  def self.down
    drop_table :exception_logs
  end
end
