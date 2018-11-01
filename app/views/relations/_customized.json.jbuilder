additions ||= []

json.extract!(record,
  :schema, :id, :uuid, :name, :description, :reverse_name, :from_kind_id,
  :to_kind_id, :abstract
)

if additions.request?('technical')
  json.created_at record.created_at
  json.updated_at record.updated_at
  json.lock_version record.lock_version
end

if additions.request?('inheritance')
  json.extract! record, :parent_ids, :child_ids, :removable
end