additions ||= []

json.extract! credential, :id, :name, :description, :lock_version

if additions.request?('technical')
  json.extract! credential, :created_at, :updated_at
end