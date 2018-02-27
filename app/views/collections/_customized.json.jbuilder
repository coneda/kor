additions ||= []

# TODO: make sure the lock_version is available with all resources by default
json.extract! kor_collection, :id, :name, :lock_version

if additions.request?('counts')
  json.extract! kor_collection, :entity_count  
end

if additions.request?('technical')
  json.created_at kor_collection.created_at
  json.updated_at kor_collection.updated_at
end