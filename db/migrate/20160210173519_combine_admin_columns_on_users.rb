class CombineAdminColumnsOnUsers < ActiveRecord::Migration
  def up
    User.all.each do |user|
      user.update(
        admin: user.credential_admin ||
          user.collection_admin ||
          user.user_admin ||
          user.admin ||
          user.developer
      )
    end

    change_table :users do |t|
      t.remove :credential_admin
      t.remove :collection_admin
      t.remove :user_admin
      t.remove :developer
      t.remove :rating_admin
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
