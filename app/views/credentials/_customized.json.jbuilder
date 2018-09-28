additions ||= []

json.extract! record, :id, :name, :description

if additions.request?('counts')
  json.extract! record, :user_count
end

if additions.request?('technical')
  json.extract! record, :lock_version, :created_at, :updated_at
end