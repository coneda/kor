class Identifier < ApplicationRecord
  belongs_to :entity

  validates :kind, :value, :presence => true
  validates :kind, :uniqueness => { :scope => :entity_id }

  def self.resolve!(id, kind)
    id = if kind.present?
      case kind
      when "id" then Entity.find_by!(id: id)
      when "uuid" then Entity.find_by!(uuid: id)
      else
        find_by!(kind: kind, value: id).entity
      end
    else
      Entity.
        joins('LEFT JOIN identifiers i ON i.entity_id = entities.id').
        find_by!('entities.id = :id OR uuid = :id OR i.value = :id', id: id)
    end
  end

  def self.resolve(id, kind)
    resolve!(id, kind)
  rescue ActiveRecord::RecordNotFound => e
    nil
  end
end
