class AddApiKeyToUsers < ActiveRecord::Migration
  def up
    unless column_exists?(:users, :api_key)
      add_column :users, :api_key, :string
    end

    User.reset_column_information

    User.all.each do |user|
      user.update_column :api_key, SecureRandom.hex(48)
    end
  end

  def down
    remove_column :users, :api_key
  end
end
