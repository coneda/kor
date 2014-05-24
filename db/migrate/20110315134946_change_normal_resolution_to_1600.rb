class ChangeNormalResolutionTo1600 < ActiveRecord::Migration
  def self.up
    Medium.all.each do |medium|
      medium.image.reprocess! if medium.image.file?
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
