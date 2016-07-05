json.array! @fields do |item|
  json.partial! 'fields/customized', field: item
end