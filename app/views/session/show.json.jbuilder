if flash[:notice]
  json.notice flash[:notice]
end

json.session do
  json.locale Kor.settings['default_locale']
  json.csrfToken form_authenticity_token

  if current_user
    json.locale current_user.locale || Kor.settings['default_locale']

    if key = session[:auth_source]
      source = Kor::Auth.sources[key]

      json.auth_source do
        json.id key
        json.type source['type']
        json.password_reset_url source['password_reset_url']
      end
    end

    json.user do
      json.partial! 'users/customized', {
        record: current_user,
        inclusion: ['permissions']
      }
    end
  end
end
