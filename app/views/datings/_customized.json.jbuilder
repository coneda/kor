json.extract!(record,
  :id, :entity_id, :label, :dating_string, :from_day, :to_day
)

if inclusion.request?('technical')
  json.extract! record, :lock_version
end