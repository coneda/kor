json.info do
  json.product 'ConedaKOR'
  json.version Kor.version
  json.operator Kor.config['maintainer']['name']
  json.email Kor.config['maintainer']['email']
  json.url root_url
  json.uuid Kor.repository_uuid
end