additions ||= []

json.id collection.id
json.name collection.name

if additions.include?('technical')
  json.created_at collection.created_at
  json.updated_at collection.updated_at
  json.lock_version collection.lock_version
end