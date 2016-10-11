json.array! @types do |type|
  json.name type.name
  json.label type.label

  json.fields type.fields do |field|
    json.name field['name']
  end
end