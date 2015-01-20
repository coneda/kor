class RemoveShowLabelFromGenerators < ActiveRecord::Migration
  def up
    remove_column :generators, :show_label
  end

  def down
    add_column :generators, :show_label, :string
  end
end
