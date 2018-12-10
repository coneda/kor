class AddFields < ActiveRecord::Migration
  def self.up
    create_table :fields do |t|
      t.integer :kind_id
      t.string :type

      t.string :name
      t.string :show_label
      t.string :form_label
      t.string :search_label

      t.text :settings

      t.timestamps
    end

    Field.reset_column_information

    Kind.all.each do |kind|
      unless kind.settings[:schema].blank?
        kind.fields += kind.settings[:schema].map do |s|
          klass = "Fields::#{s['class'].classify}".constantize
          s['show_label'] = s['label'] || s['class'].classify
          s['name'] ||= s['class'].underscore
          s.delete 'label'
          s.delete 'class'
          result = klass.new s
          p result.errors unless result.valid?
          result
        end
        kind.settings[:schema] = nil
        kind.save!
      end
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
