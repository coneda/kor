additions ||= []

json.extract! generator, :id, :kind_id, :name, :directive, :errors

if additions.include?('technical') || additions.include?('all')
  json.created_at generator.created_at
  json.updated_at generator.updated_at
end