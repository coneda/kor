additions ||= []

json.id generator.id
json.kind_id generator.kind_id
json.name generator.name
json.directive generator.directive

if additions.include?('technical') || additions.include?('all')
  json.created_at generator.created_at
  json.updated_at generator.updated_at
end