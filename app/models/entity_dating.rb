class EntityDating < Dating
  belongs_to :owner,
    class_name: 'Entity',
    foreign_key: 'entity_id',
    touch: true,
    optional: true
end
