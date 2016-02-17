json.id entity.id
json.kind_id entity.kind_id
json.kind_name entity.kind.name
json.name entity.name
json.distinct_name entity.distinct_name

if entity.is_medium?
  json.url entity.medium.url(:thumbnail)
  json.content_type entity.medium.content_type
end