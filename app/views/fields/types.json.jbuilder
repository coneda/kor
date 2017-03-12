json.array! @types do |type|
  json.name type.name
  json.label type.label
  json.fields type.fields
end