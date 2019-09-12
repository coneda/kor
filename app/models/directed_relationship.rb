class DirectedRelationship < ApplicationRecord
  belongs_to :relationship
  belongs_to :relation
  belongs_to :from, class_name: 'Entity'
  belongs_to :to, class_name: 'Entity'

  scope :with_from, lambda{
    joins('LEFT JOIN entities froms ON froms.id = directed_relationships.from_id')
  }
  scope :with_to, lambda{
    joins('LEFT JOIN entities tos ON tos.id = directed_relationships.to_id')
  }
  def self.allowed(user, policy = :view)
    collection_ids = Kor::Auth.authorized_collections(user, policy).map{ |c| c.id }
    with_from.where('froms.collection_id IN (?)', collection_ids).
      with_to.where('tos.collection_id IN (?)', collection_ids)
  end
  scope :by_from_entity, lambda{ |entity_id|
    entity_id.present? ? where(from_id: entity_id) : all
  }
  scope :by_to_entity, lambda{ |entity_id|
    entity_id.present? ? where(to_id: entity_id) : all
  }
  scope :by_to_name, lambda{ |entity_name|
    entity_name.present? ? with_to.where('tos.name = ?', "%#{entity_name}%") : all
  }
  scope :by_relation_name, lambda{ |relation_name|
    relation_name.present? ? where(relation_name: relation_name) : all
  }
  scope :by_from_kind, lambda{ |kind_id|
    kind_id.present? ? with_from.where('froms.kind_id IN (?)', kind_id) : all
  }
  scope :by_to_kind, lambda{ |kind_id|
    kind_id.present? ? with_to.where('tos.kind_id IN (?)', kind_id) : all
  }
  scope :except_to_kind, lambda{ |kind_id|
    kind_id.present? ? with_to.where('tos.kind_id NOT IN (?)', kind_id) : all
  }
  scope :order_by_name, lambda{
    with_to.order('tos.name ASC, directed_relationships.relationship_id ASC')
  }
end
