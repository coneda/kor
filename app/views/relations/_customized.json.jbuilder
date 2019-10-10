json.extract!(record,
  :schema, :id, :uuid, :identifier, :reverse_identifier, :name, :description,
  :reverse_name, :from_kind_id, :to_kind_id, :abstract
)

if inclusion.request?('technical')
  json.created_at record.created_at
  json.updated_at record.updated_at
  json.lock_version record.lock_version
end

if inclusion.request?('inheritance')
  json.extract! record, :parent_ids, :child_ids, :removable
end
