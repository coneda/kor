json.info do
  json.product 'ConedaKOR'
  json.version Kor.version
  json.revision Kor.commit
  json.operator Kor.settings['maintainer_name']
  json.email Kor.settings['maintainer_mail']
  json.legal_html Kor.settings['legal_html']
  # TODO: imeplement this:
  # json.federation_auth Kor.federation_auth?
  json.url root_url
  json.uuid Kor.repository_uuid
  json.source_code_url Kor.source_code_url
  json.locales I18n.available_locales
  json.medium_kind_id Kind.medium_kind_id
  json.env Rails.env.to_s
  json.elastic Kor::Elastic.available?
  json.static static_mode?

  url = Kor.settings['custom_css_file']
  if url.present?
    json.custom_css url
  end
end
