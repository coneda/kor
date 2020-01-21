class AddPositionToGenerator < ActiveRecord::Migration
  def up
    add_column :generators, :position, :integer

    Kind.all.each do |kind|
      kind.generators.each.with_index do |generator, i|
        generator.update_column :position, i
      end
    end
  end

  def down
    remove_column :generators, :position
  end
end
