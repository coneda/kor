json.extract! record, :id, :name, :description

if inclusion.request?('counts')
  json.extract! record, :user_count
end

if inclusion.request?('technical')
  json.extract! record, :lock_version, :created_at, :updated_at
end
