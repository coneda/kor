additions ||= []

json.id user.id
json.name user.name
json.full_name user.full_name
json.locale user.locale
json.admin user.admin
json.kind_admin user.kind_admin
json.authority_group_admin user.authority_group_admin
json.relation_admin user.relation_admin

if additions.include?('security') && (current_user.admin? || current_user == user)
  json.email user.email
  json.last_login user.last_login
  json.active user.active?
  json.last_login user.last_login
  json.expires_at user.expires_at
  json.terms_accepted user.terms_accepted?
  json.parent_username user.parent_username
  json.api_key user.api_key
end

if additions.include?('technical')
  json.lock_version user.lock_version
  json.created_at user.created_at
  json.updated_at user.updated_at
end
