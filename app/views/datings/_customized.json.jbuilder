additions ||= []

json.id dating.id
json.entity_id dating.entity_id
json.dating_string dating.dating_string
json.from_day dating.from_day
json.to_day dating.to_day

if additions.include?('technical')
  json.lock_version dating.lock_version
end