class RelationInheritance < ApplicationRecord
  belongs_to :parent, class_name: 'Relation'
  belongs_to :child, class_name: 'Relation'
end