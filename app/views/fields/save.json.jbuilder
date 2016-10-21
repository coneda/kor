json.message @message
json.record do
  json.partial! 'customized', field: @field
end
