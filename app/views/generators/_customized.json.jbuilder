json.extract! record, :id, :kind_id, :name, :directive

if inclusion.request?('technical')
  json.created_at record.created_at
  json.updated_at record.updated_at
end
