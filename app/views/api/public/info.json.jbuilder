json.info do
  json.version Kor.version
  json.maintainer "Coneda UG"
  json.url root_url
end

json.stats do
  json.entities Entity.count
  json.kinds Kind.count
  json.relations Relation.count
  json.relationships Relationship.count
  json.users User.count
end

json.session do
  json.user do
    if current_user
      json.display_name current_user.display_name
      json.id current_user.id
      json.name current_user.name
      json.email current_user.email
      json.auth current_user.full_auth
      json.locale current_user.locale

      unless current_user.guest?
        json.history current_user.history
        json.clipboard current_user.clipboard
      end
    end
  end
  json.flash do
    if current_user
      json.notice flash[:notice]
      json.error flash[:error]
    end
  end
  json.current_history @current_entities do |entity|
    json.partial! 'entities/customized', entity: entity
  end
  json.show_panel session[:show_session_info]
end

json.config do
  json.max_file_size Kor.config['app.max_file_upload_size'].to_f
end

json.translations I18n.backend.send(:translations)
json.locale I18n.locale
json.medium_kind_id Kind.medium_kind_id
json.medium_kind_uuid Kind::MEDIA_UUID