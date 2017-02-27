additions ||= []

json.extract! credential, :id, :name, :description, :lock_version

if additions.include?('technical') || additions.include?('all')
  json.extract! credential, :created_at, :updated_at
end