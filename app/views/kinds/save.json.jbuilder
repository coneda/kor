json.message @message
json.record do
  json.partial! 'customized', kind: @kind, additions: ['generators', 'fields']
end
json.errors @kind.errors