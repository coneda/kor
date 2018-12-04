json.extract!(record,
  :id, :name, :full_name, :display_name, :admin, :kind_admin,
  :authority_group_admin, :relation_admin, :default_collection_id,
  :terms_accepted
)

json.locale record.locale || I18n.default_locale.to_s

if inclusion.request?('technical')
  json.extract! record, :lock_version, :created_at, :updated_at
end

if current_user.admin? || (current_user == record)
  json.guest record.guest?

  if inclusion.request?('security')
    json.extract!(record,
      :email, :last_login, :active, :expires_at, :parent_username, :api_key
    )
    json.personal record.personal?
    json.group_ids record.groups.pluck(:id)
  end

  # if inclusion.request?('data') && !record.guest?
  #   json.extract! record, :history, :clipboard
  # end

  if inclusion.request?('permissions')
    json.permissions record.full_auth
  end
end

