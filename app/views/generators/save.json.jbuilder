json.message @message

json.record do
  json.partial! 'customized', generator: @generator
end
