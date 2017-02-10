class EntityDating < Dating

  belongs_to :owner, class_name: 'Entity'

end
