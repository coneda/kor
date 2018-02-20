additions ||= []

json.extract! generator, :id, :kind_id, :name, :directive

if additions.request?('technical')
  json.created_at generator.created_at
  json.updated_at generator.updated_at
end