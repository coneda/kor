additions ||= []
dr = directed_relationship

json.relationship_id dr.relationship_id
json.from_id dr.from_id
json.to_id dr.to_id
json.is_reverse dr.is_reverse
json.relation_name dr.relation_name

if additions.include?('technical') || additions.include?('all')
  json.created_at dr.created_at
  json.updated_at dr.updated_at
end

if additions.include?('to') || additions.include?('all')
  json.to do
    json.partial! 'entities/customized', entity: dr.to
  end
end