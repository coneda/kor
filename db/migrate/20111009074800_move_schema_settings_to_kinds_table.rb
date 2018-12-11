class MoveSchemaSettingsToKindsTable < ActiveRecord::Migration
  def self.up
    old_config_file = "#{Rails.root}/config/schema_definitions.yml"
    unless File.exist? old_config_file
      old_config_file = File.expand_path(Rails.root + '../../shared/schema_definitions.yml')
    end

    old_config = begin
      YAML.load_file old_config_file
    rescue
      file = Dir["#{Rails.root}/../releases/*/config/schema_definitions.yml"].last
      file ? YAML.load_file(file) : nil
    end

    if old_config
      Kind.all.each do |kind|
        kind.settings[:schema] = old_config[kind.schema_name]
        kind.save
      end

      change_table :kinds do |t|
        t.remove :attachment_class
        t.remove :schema_name
      end
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
