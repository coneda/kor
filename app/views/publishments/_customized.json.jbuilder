json.extract! record, 
  :id, :name, :user_group_id, :user_group_name, :user_id, :valid_until

json.link "/pub/#{record.user_id}/#{record.uuid}"

if inclusion.request?('technical')
  json.extract! record, :uuid, :lock_version, :created_at, :updated_at
end
