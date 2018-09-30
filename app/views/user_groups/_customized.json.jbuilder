json.extract! record, :id, :name, :shared, :user_id

if inclusion.request?('owner')
  json.owner do
    json.partial! 'users/customized', {
      record: record.owner
    }
  end
end

if inclusion.request?('technical')
  json.extract! record, :uuid, :lock_version, :created_at, :updated_at
end
