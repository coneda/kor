class UnifyGndReferences < ActiveRecord::Migration
  def up
    # Code is already present in 20141209173305_unify_web_services
    
    # scope = Entity

    # scope.find_each do |e|
    #   unless e.dataset.empty?
    #     new_refs = e.dataset.dup
    #     all_refs = e.dataset.values_at("pnd", "knd", "gnd")
    #     all_filtered = all_refs.select{|e| e.present?}
    #     value = all_filtered.last.presence
    #     new_refs.delete "pnd"
    #     new_refs.delete "knd"
    #     if value.present?
    #       new_refs["gnd"] = value
    #     else
    #       new_refs.delete "gnd"
    #     end

    #     if new_refs != e.dataset
    #       attachment = e.attachment
    #       attachment["fields"] = new_refs
    #       e.update_column :attachment, JSON.dump(attachment)
    #     end
    #   end
    # end
  end

  def down
    # raise ActiveRecord::IrreversibleMigration
  end
end
