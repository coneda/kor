class AddDeletedAt < ActiveRecord::Migration
  def change
    [:kinds, :entities, :relations, :relationships].each do |t|
      add_column t, :deleted_at, :datetime
      add_index t, :deleted_at
    end
  end
end
