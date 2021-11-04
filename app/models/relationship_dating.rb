class RelationshipDating < Dating
  belongs_to :owner, class_name: 'Relationship', touch: true, optional: true
end
