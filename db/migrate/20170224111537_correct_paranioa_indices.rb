class CorrectParanioaIndices < ActiveRecord::Migration
  def change
    [:kinds, :entities, :relations, :relationships].each do |t|
      remove_index t, name: "index_#{t}_on_deleted_at"
      add_index t, [:id, :deleted_at], name: 'deleted_at_partial'
    end
  end
end
