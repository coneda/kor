additions ||= []
dr = directed_relationship

json.extract!(dr,
  :id, :relationship_id, :from_id, :to_id, :is_reverse, :relation_name,
  :relation_id,
)

if additions.request?('technical')
  json.created_at dr.created_at
  json.updated_at dr.updated_at
end

if additions.request?('to')
  json.to do
    json.partial! 'entities/customized', entity: dr.to
  end
end

if additions.request?('properties')
  json.properties dr.relationship.properties
end

if additions.request?('datings')
  json.datings dr.relationship.datings do |dating|
    json.extract! dating, :id, :label, :dating_string, :lock_version
  end
end

if additions.request?('relationship')
  json.relationship do
    json.partial! 'relationships/normal', relationship: dr.relationship
  end
end

if additions.request?('media_relations')
  json.media_relations dr.to.media_count(current_user)
end