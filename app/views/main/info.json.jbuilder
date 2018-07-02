json.info do
  json.product 'ConedaKOR'
  json.version Kor.version
  json.operator Kor.settings['maintainer_name']
  json.email Kor.settings['maintainer_mail']
  # TODO: imeplement this:
  # json.federation_auth Kor.federation_auth?
  json.url root_url
  json.uuid Kor.repository_uuid
  json.source_code_url Kor.source_code_url
  json.locales I18n.available_locales
  json.medium_kind_id Kind.medium_kind_id
end