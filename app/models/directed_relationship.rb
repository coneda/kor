class DirectedRelationship < ActiveRecord::Base

  belongs_to :relationship
  belongs_to :relation
  belongs_to :from, class_name: 'Entity'
  belongs_to :to, class_name: 'Entity'

  scope :by_name, lambda {|name|
    name.present? ? where(relation_name: name) : all
  }
  def self.authorized_for(user, policy = :view)
    collection_ids = Kor::Auth.authorized_collections(user, policy).map{|c| c.id}
    joins('LEFT JOIN entities tos ON tos.id = directed_relationships.to_id').
      where('tos.collection_id IN (?)', collection_ids)
  end

  def properties
    self.relationship.properties
  end

end