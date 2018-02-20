additions ||= []

json.extract!(relation,
  :schema, :id, :uuid, :name, :description, :reverse_name, :from_kind_id,
  :to_kind_id
)

if additions.request?('technical')
  json.created_at relation.created_at
  json.updated_at relation.updated_at
  json.lock_version relation.lock_version
end

if additions.request?('inheritance')
  json.extract! relation, :parent_ids, :child_ids, :removable
end