json.total @generators.size
json.page 1
json.per_page @generators.size
json.records do
  json.array! @generators do |item|
    json.partial! 'customized', generator: item
  end
end