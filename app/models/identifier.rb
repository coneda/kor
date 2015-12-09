class Identifier < ActiveRecord::Base

  belongs_to :entity, :foreign_key => :entity_uuid, :primary_key => :uuid

  validates :entity_uuid, :kind, :value, :presence => true
  validates :kind, :uniqueness => {:scope => :entity_uuid}

  def self.resolve(kind, id)
    id = if kind.present?
      where(:kind => kind, :value => id).first.try(:entity)
    else
      Entity.where(:id => id).first || 
      Entity.where(:uuid => id).first ||
      Identifier.where(:value => id).first.try(:entity)
    end
  end

end