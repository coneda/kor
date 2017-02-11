additions ||= []
dr = directed_relationship

json.extract!(dr,
  :id, :relationship_id, :from_id, :to_id, :is_reverse, :relation_name,
  :relation_id,
)

if additions.include?('technical') || additions.include?('all')
  json.created_at dr.created_at
  json.updated_at dr.updated_at
end

if additions.include?('to') || additions.include?('all')
  json.to do
    json.partial! 'entities/customized', entity: dr.to
  end
end

if additions.include?('properties') || additions.include?('all')
  json.properties dr.relationship.properties
end

if additions.include?('datings') || additions.include?('all')
  json.datings dr.relationship.datings do |dating|
    json.extract! dating, :id, :label, :dating_string, :lock_version
  end
end

if additions.include?('relationship') || additions.include?('all')
  json.relationship do
    json.partial! 'relationships/normal', relationship: dr.relationship
  end
end

if additions.include?('media_relations') || additions.include?('all')
  json.media_relations dr.to.media_count(current_user)
end