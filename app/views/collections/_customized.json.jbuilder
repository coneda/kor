additions ||= []

json.extract! kor_collection, :id, :name, :lock_version

if additions.request?('technical')
  json.created_at kor_collection.created_at
  json.updated_at kor_collection.updated_at
end