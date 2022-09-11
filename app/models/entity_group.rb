class EntityGroup < ApplicationRecord
  self.abstract_class = true

  scope :named_like, lambda{ |pattern| where("name LIKE ?", "%#{pattern}%") }

  validates :name, {
    presence: true,
    white_space: true
  }

  after_validation(:on => :create) do |model|
    model.uuid = SecureRandom.uuid
  end

  def self.search(terms)
    terms.present? ? where('name LIKE ?', "%#{terms}%") : all
  end

  def add_entities(new_entities)
    new_entities = [new_entities] unless new_entities.is_a? Array
    new_entities.reject{ |e| self.entity_ids.include? e.id }.each do |e|
      entities << e
    end
  end

  def remove_entities(old_entities)
    entities.delete(old_entities)
  end
end
