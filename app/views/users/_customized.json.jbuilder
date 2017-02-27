additions ||= []

json.extract!(user,
  :id, :name, :full_name, :locale, :admin, :kind_admin, :authority_group_admin,
  :relation_admin
)

if additions.include?('security') && (current_user.admin? || current_user == user)
  json.extract!(user,
    :email, :last_login, :active, :expires_at, :terms_accepted,
    :parent_username, :api_key
  )
  json.personal user.personal?
  json.group_ids user.groups.pluck(:id)
end

if additions.include?('technical')
  json.extract! user, :lock_version, :created_at, :updated_at
end
