class KindInheritance < ApplicationRecord
  belongs_to :parent, class_name: 'Kind', optional: true
  belongs_to :child, class_name: 'Kind', optional: true
end
