class UnifyDataset < ActiveRecord::Migration
  def up
    Entity.find_each do |entity|
      if entity.attachment['dataset'].present?
        keys = entity.dataset.keys & (entity.attachment['dataset'] || {}).keys

        if keys.empty? || keys.all?{ |k| entity.dataset[k] == entity.attachment['dataset'][k] }
          new_value = entity.attachment
          new_value['fields'] ||= {}
          new_value['fields'].merge! new_value['dataset'] || {}
          new_value.delete 'dataset'
          entity.update_column :attachment, new_value
        else
          raise "Entity #{entity.id} has conflicting dataset and fields, please fix the issue and re-run the migration"
        end
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
