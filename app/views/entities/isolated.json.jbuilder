json.total @result.total
json.page @result.page
json.per_page @result.per_page
json.total_pages @result.total_pages
json.records do
  json.array! @result.records do |entity|
    json.id entity.id
    json.kind_id entity.kind_id
    json.kind_name entity.kind.name
    json.name entity.name
    json.distinct_name entity.distinct_name
  end
end