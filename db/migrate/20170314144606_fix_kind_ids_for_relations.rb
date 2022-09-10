class FixKindIdsForRelations < ActiveRecord::Migration
  def change
    Relation.all.each do |relation|
      new_data = YAML.load(relation.from_kind_ids).select{ |i| i > 0 }
      relation.update_column :from_kind_ids, YAML.dump(new_data)

      new_data = YAML.load(relation.to_kind_ids).select{ |i| i > 0 }
      relation.update_column :to_kind_ids, YAML.dump(new_data)
    end
  end
end
