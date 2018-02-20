additions ||= []

json.id authority_group.id
json.name authority_group.name
json.authority_group_category_id authority_group.authority_group_category_id

if additions.request?('technical')
  json.uuid authority_group.uuid
  json.lock_version authority_group.lock_version
  json.created_at authority_group.created_at
  json.updated_at authority_group.updated_at
end
