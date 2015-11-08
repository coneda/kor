class AddApiKeyToUsers < ActiveRecord::Migration
  def up
    add_column :users, :api_key, :string

    User.reset_column_information

    User.all.each do |user|
      user.update_column :api_key, SecureRandom.hex(48)
    end
  end

  def down
    remove_column :users, :api_key
  end
end
