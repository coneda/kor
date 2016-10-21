json.message @message
json.record do
  json.partial! 'customized', kind: @kind
end
json.errors @kind.errors