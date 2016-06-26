additions ||= []

json.id kor_collection.id
json.name kor_collection.name

if additions.include?('technical')
  json.created_at kor_collection.created_at
  json.updated_at kor_collection.updated_at
  json.lock_version kor_collection.lock_version
end