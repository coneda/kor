class SimplyfiedRelationNaming < ActiveRecord::Migration
  def self.up
    Relation.all.each do |r|
      r.name = r.translated_name
      r.reverse_name = r.translated_reverse_name
      r.save
    end
  end

  def self.down
  end
end
