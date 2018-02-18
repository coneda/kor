json.messages @messages

json.record do
  json.partial! 'customized', field: @field, additions: ['all']
end
