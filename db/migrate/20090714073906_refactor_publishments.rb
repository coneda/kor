class RefactorPublishments < ActiveRecord::Migration
  def self.up
    remove_column :publishments, :tag_id
    add_column :publishments, :user_group_id, :integer
  end

  def self.down
    add_column :publishments, :tag_id, :integer
    remove_column :publishments, :user_group_id
  end
end
