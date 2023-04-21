class RemoveExceptionLogs < ActiveRecord::Migration[5.0]
  def change
    drop_table :exception_logs
  end
end
