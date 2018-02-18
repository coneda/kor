json.total @fields.size
json.page 1
json.per_page @fields.size
json.records do
  json.array! @fields do |item|
    json.partial! 'customized', field: item
  end
end