class AddProcessingStateToMedia < ActiveRecord::Migration
  def self.up
    add_column :media, :document_processing, :boolean
    add_column :media, :image_processing, :boolean
  end

  def self.down
    remove_column :media, :document_processing
    remove_column :media, :image_processing
  end
end
