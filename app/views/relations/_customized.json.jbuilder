additions ||= []

json.extract!(relation,
  :id, :uuid, :name, :description, :reverse_name, :from_kind_id, :to_kind_id
)

if additions.include?('technical') || additions.include?('all')
  json.created_at relation.created_at
  json.updated_at relation.updated_at
  json.lock_version relation.lock_version
end

if additions.include?('inheritance') || additions.include?('all')
  json.extract! relation, :parent_ids, :child_ids, :removable
end