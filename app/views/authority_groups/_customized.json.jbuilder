json.extract! record, :id, :name, :authority_group_category_id

if inclusion.request?('technical')
  json.extract! record, :uuid, :locl_version, :created_at, :updated_at
end
