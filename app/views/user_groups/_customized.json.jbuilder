additions ||= []

json.id user_group.id
json.name user_group.name
json.shared !!user_group.shared
json.user_id user_group.user_id

if additions.request?('user')
  json.user do
    json.partial! 'users/customized', {
      user: user_group.user, additions: additions
    }
  end
end

if additions.request?('technical')
  json.uuid user_group.uuid
  json.lock_version user_group.lock_version
  json.created_at user_group.created_at
  json.updated_at user_group.updated_at
end
