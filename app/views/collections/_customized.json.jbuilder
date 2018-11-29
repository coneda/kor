# TODO: make sure the lock_version is available with all resources by default
json.extract! record, :id, :name, :lock_version

if inclusion.request?('permissions')
  json.extract! record, :permissions
end

if inclusion.request?('counts')
  json.extract! record, :entity_count  
end

if inclusion.request?('owner')
  if record.owner
    json.owner do
      json.partial! 'users/customized', {record: record.owner}
    end
  end
end

if inclusion.request?('technical')
  json.extract! record, :lock_version, :created_at, :updated_at
end