json.messages @messages

json.record do
  json.partial! 'customized', kind: @kind, additions: ['all']
end

json.errors @kind.errors