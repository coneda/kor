class RemoveNeedlessWhiteSpace < ActiveRecord::Migration
  def up
    schema_set = {
      Entity => [:name, :distinct_name],
      UserGroup => [:name],
      SystemGroup => [:name],
      AuthorityGroup => [:name],
      Kind => [:name, :plural_name],
      Credential => [:name],
      Collection => [:name],
      User => [:name, :email]
    }

    schema_set.each do |model, attributes|
      attributes.each do |attribute|
        model.where("#{attribute} LIKE ? OR #{attribute} LIKE ? OR #{attribute} LIKE ?", " %", "% ", "  ").each do |record|
          old_value = record.send(attribute)
          new_value = record.send(attribute).
            gsub(/^\s+/, '').
            gsub(/\s+$/, '').
            gsub(/\s{2,}/, ' ')

          record.update_column attribute, new_value
        end
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
