class AddDefault0ToLockVersionEverywhere < ActiveRecord::Migration[5.0]
  def up
    tables = [
      :authority_group_categories,
      :authority_groups,
      :collections,
      :entity_datings,
      :media,
      :relationship_datings,
      :system_groups,
      :user_groups
    ]

    tables.each do |t|
      change_column t, :lock_version, :integer, default: 0
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
