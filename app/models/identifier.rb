class Identifier < ActiveRecord::Base

  belongs_to :entity

  validates :kind, :value, :presence => true
  validates :kind, :uniqueness => {:scope => :entity_id}

  def self.resolve(id, kind)
    id = if kind.present?
      case kind
        when "id" then Entity.where(:id => id).first
        when "uuid" then Entity.where(:uuid => id).first
        else
          where(:kind => kind, :value => id).first.try(:entity)
      end
    else
      Entity.where(:id => id).first || 
      Entity.where(:uuid => id).first ||
      Identifier.where(:value => id).first.try(:entity)
    end
  end

end