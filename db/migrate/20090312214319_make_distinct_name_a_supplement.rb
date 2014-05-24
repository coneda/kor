class MakeDistinctNameASupplement < ActiveRecord::Migration
  def self.up
    Entity.all.each do |e|
      unless e.distinct_name.blank?
        e.distinct_name = e.distinct_name.gsub(e.name || "lkjh.qwersdfg-.,.-asdf", "").gsub(/^[ ,]*|[, ]*$/, "")
        e.save(false)
      end
    end
  end

  def self.down
    raise ActiveSupport::IrreversibleMigration
  end
end
