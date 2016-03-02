class GenerateUuidForAllKinds < ActiveRecord::Migration
  def up
    Kind.all.each do |kind|
      unless kind.uuid.present?
        kind.update_column :uuid, SecureRandom.uuid
      end
    end
  end

  def down
    raise IrreversibleMigration
  end
end
