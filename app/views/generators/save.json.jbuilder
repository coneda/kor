json.messages @messages

json.record do
  json.partial! 'customized', generator: @generator, additions: ['all']
end

json.errors @kind.errors