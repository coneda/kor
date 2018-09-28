json.extract! record, :id, :name, :authority_group_category_id

if inclusion.request?('technical')
  json.extract! record, :uuid, :lock_version, :created_at, :updated_at
end
