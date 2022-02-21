class FixStringSynonyms < ActiveRecord::Migration
  def up
    Entity.find_each do |e|
      existing = e.attachment["synonyms"]
      if existing.is_a?(String)
        value = (existing.present? ? existing : [])
        e.update :synonyms => value
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
