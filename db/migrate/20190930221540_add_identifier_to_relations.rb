class AddIdentifierToRelations < ActiveRecord::Migration[5.0]
  def change
    change_table :relations do |t|
      t.string :identifier
      t.string :reverse_identifier
    end

    Relation.all.each do |r|
      r.update_columns(
        identifier: r.name.downcase.downcase.gsub(/[^a-z]/, '_'),
        reverse_identifier: r.reverse_name.downcase.downcase.gsub(/[^a-z]/, '_')
      )
    end
  end

  def down
    change_table :relations do |t|
      t.drop :identifier
      t.drop :reverse_identifier
    end
  end
end
