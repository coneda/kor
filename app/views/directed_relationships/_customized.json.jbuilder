json.extract!(record,
  :id, :relationship_id, :from_id, :to_id, :is_reverse, :relation_name,
  :relation_id,
)

if inclusion.request?('to')
  json.to do
    json.partial! 'entities/customized', entity: record.to
  end
end

if inclusion.request?('properties')
  json.properties record.relationship.properties
end

if inclusion.request?('datings')
  json.datings record.relationship.datings do |dating|
    json.extract! dating, :id, :label, :dating_string, :lock_version
  end
end

if inclusion.request?('relationship')
  json.relationship do
    json.partial! 'relationships/normal', relationship: record.relationship
  end
end

if inclusion.request?('media_relations')
  json.media_relations record.to.media_count(current_user)
end

if inclusion.request?('technical')
  json.created_at record.created_at
  json.updated_at record.updated_at
end