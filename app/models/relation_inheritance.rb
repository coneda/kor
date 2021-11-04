class RelationInheritance < ApplicationRecord
  belongs_to :parent, class_name: 'Relation', optional: true
  belongs_to :child, class_name: 'Relation', optional: true
end
