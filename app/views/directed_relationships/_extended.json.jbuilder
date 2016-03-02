json.id directed_relationship.id
json.relationship_id directed_relationship.relationship_id
json.relation_id directed_relationship.relation_id
json.relation_name directed_relationship.relation_name
json.from_id directed_relationship.from_id
json.to_id directed_relationship.to_id
json.is_reverse directed_relationship.is_reverse
json.created_at directed_relationship.created_at
json.updated_at directed_relationship.updated_at

json.relationship do
  json.partial!('relationships/normal',
    relationship: directed_relationship.relationship
  )
end

json.to do
  json.partial! 'entities/minimal', entity: directed_relationship.to
end

json.media_count directed_relationship.to.media_count(current_user)