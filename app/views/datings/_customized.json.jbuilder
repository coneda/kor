additions ||= []

json.id dating.id
json.entity_id dating.entity_id
json.label dating.label
json.dating_string dating.dating_string
json.from_day dating.from_day
json.to_day dating.to_day

if additions.request?('technical')
  json.lock_version dating.lock_version
end