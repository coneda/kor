json.messages @messages

json.record do
  json.partial! 'customized', relationship: @relationship
end

json.errors @relationship.errors