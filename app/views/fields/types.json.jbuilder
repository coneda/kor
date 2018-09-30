json.array! @types do |type|
  json.extract! type, :name, :label, :fields
end