json.messages @messages

json.record do
  json.partial! 'customized', relation: @relation, additions: ['all']
end

json.errors @relation.errors