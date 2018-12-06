class KindInheritance < ApplicationRecord
  belongs_to :parent, class_name: 'Kind'
  belongs_to :child, class_name: 'Kind'
end