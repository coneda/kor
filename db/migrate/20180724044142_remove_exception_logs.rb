class RemoveExceptionLogs < ActiveRecord::Migration
  def change
    drop_table :exception_logs
  end
end
