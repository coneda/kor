class AddUpdatedByToEntities < ActiveRecord::Migration
  def self.up
    change_table :entities do |t|
      t.rename :user_id, :creator_id
      t.integer :updater_id
    end
  end

  def self.down
    change_table :entities do |t|
      t.remove :updater_id
      t.rename :creator_id, :user_id
    end
  end
end
