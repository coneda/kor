additions ||= []

json.extract!(user,
  :id, :name, :full_name, :display_name, :locale, :admin, :kind_admin,
  :authority_group_admin, :relation_admin, :default_collection_id,
  :terms_accepted
)

if additions.request?('technical')
  json.extract! user, :lock_version, :created_at, :updated_at
end

if current_user.admin? || (current_user == user)
  json.guest user.guest?

  if additions.request?('security')
    json.extract!(user,
      :email, :last_login, :active, :expires_at, :parent_username, :api_key
    )
    json.personal user.personal?
    json.group_ids user.groups.pluck(:id)
  end

  if additions.request?('data') && !user.guest?
    json.extract! user, :history, :clipboard
  end

  if additions.request?('auth')
    json.permissions user.full_auth
  end
end

