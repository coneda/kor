class RelationshipDating < Dating
  belongs_to(:owner,
    class_name: 'Relationship',
    foreign_key: 'relationship_id',
    touch: true,
    optional: true
  )
end
