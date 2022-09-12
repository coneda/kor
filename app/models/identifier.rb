class Identifier < ApplicationRecord
  belongs_to :entity

  validates :kind, :value, presence: true
  validates :kind, uniqueness: {scope: :entity_id, case_sensitive: true}

  def self.resolve!(id, kind)
    if kind.present?
      case kind
      when 'id' then Entity.find_by!(id: id)
      when 'uuid' then Entity.find_by!(uuid: id)
      when 'medium-id' then Entity.find_by!(medium_id: id)
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
  rescue ActiveRecord::RecordNotFound
    nil
  end
end
