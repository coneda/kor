additions ||= []

# TODO: make sure the lock_version is available with all resources by default
json.extract! kor_collection, :id, :name, :lock_version

if additions.request?('permissions')
  json.extract! kor_collection, :permissions
end

if additions.request?('counts')
  json.extract! kor_collection, :entity_count  
end

if additions.request?('technical')
  json.extract! kor_collection, :lock_version, :created_at, :updated_at
end