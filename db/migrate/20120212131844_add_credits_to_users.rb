class AddCreditsToUsers < ActiveRecord::Migration
  def change
    create_table :engagements do |t|
      t.integer :user_id

      t.string :kind

      t.string :related_type
      t.integer :related_id

      t.integer :credits

      t.timestamps
    end

    add_index :engagements, [:user_id, :kind, :related_type, :related_id], :name => 'lookup'
  end
end
