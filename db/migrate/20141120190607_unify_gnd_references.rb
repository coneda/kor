class UnifyGndReferences < ActiveRecord::Migration
  def up
    scope = Entity

    scope.find_each do |e|
      unless e.external_references.empty?
        new_refs = e.external_references.dup
        all_refs = e.external_references.values_at("pnd", "knd", "gnd")
        all_filtered = all_refs.select{|e| e.present?}
        value = all_filtered.last.presence
        new_refs.delete "pnd"
        new_refs.delete "knd"
        if value.present?
          new_refs["gnd"] = value
        else
          new_refs.delete "gnd"
        end

        if new_refs != e.external_references
          e.update_column :external_references, YAML.dump(new_refs)
        end
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
