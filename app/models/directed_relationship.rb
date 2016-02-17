class DirectedRelationship < ActiveRecord::Base

  belongs_to :relationship
  belongs_to :relation
  belongs_to :from, class_name: 'Entity'
  belongs_to :to, class_name: 'Entity'

  scope :by_name, lambda {|name|
    name.present? ? where(relation_name: name) : all
  }
  def self.allowed(user, policy = :view)
    collection_ids = Kor::Auth.authorized_collections(user, policy).map{|c| c.id}
    joins('LEFT JOIN entities tos ON tos.id = directed_relationships.to_id').
      where('tos.collection_id IN (?)', collection_ids)
  end
  scope :pageit, lambda { |page, per_page|
    page = (page || 1).to_i - 1
    per_page = [(per_page || 10).to_i, 500].min
    limit(per_page).offset(per_page * page)
  }
  scope :by_entity, lambda { |entity_id| 
    entity_id.present? ? where(from_id: entity_id) : all
  }
  scope :by_relation_name, lambda { |relation_name|
    relation_name.present? ? where(relation_name: relation_name) : all
  }

  def properties
    self.relationship.properties
  end

end