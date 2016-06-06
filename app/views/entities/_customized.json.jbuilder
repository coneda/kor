additions ||= []

json.id entity.id
json.collection_id entity.collection_id
json.kind_id entity.kind_id
json.kind_name entity.kind.name
json.name entity.name
json.distinct_name entity.distinct_name
json.display_name entity.display_name
json.comment entity.comment
json.subtype entity.subtype
json.creator_id entity.creator_id
json.updater_id entity.updater_id
json.tags entity.tag_list

if entity.is_medium?
  json.medium_id entity.medium_id

  json.medium do
    json.id entity.medium.id
    json.file_size entity.medium.file_size
    json.content_type entity.medium.content_type

    json.url do
      json.icon entity.medium.url(:icon)
      json.thumbnail entity.medium.url(:thumbnail)
      json.preview entity.medium.url(:preview)
      json.screen entity.medium.url(:screen)
      json.normal entity.medium.url(:normal)
      json.original entity.medium.url(:original)
    end
  end
end

if authorized?(:view_meta, entity.collection)
  if additions.include?('technical') || additions.include?('all')
    json.uuid entity.uuid
    json.created_at entity.created_at
    json.updated_at entity.updated_at
    json.no_name_statement entity.no_name_statement
  end
end

if additions.include?('synonyms') || additions.include?('all')
  json.synonyms entity.synonyms
end

if additions.include?('datings') || additions.include?('all')
  json.datings entity.datings do |dating|
    json.partial! 'datings/customized', dating: dating
  end
end

if additions.include?('dataset') || additions.include?('all')
  json.dataset entity.dataset
end

if additions.include?('properties') || additions.include?('all')
  json.properties entity.properties  
end

if additions.include?('relations') || additions.include?('all')
  json.relations entity.relation_counts(current_user)
end

if additions.include?('media_relations') || additions.include?('all')
  json.media_relations entity.relation_counts(current_user, media: true)
end

if additions.include?('kind') || additions.include?('all')
  json.kind do
    json.partial! 'kinds/customized', kind: entity.kind, additions: ['settings']
  end
end

if additions.include?('collection') || additions.include?('all')
  json.collection do
    json.partial! 'collections/customized', locals: {
      collection: entity.collection
    }
  end
end

if additions.include?('user_groups') || additions.include?('all')
  json.user_groups entity.user_groups.owned_by(current_user) do |user_group|
    json.partial! 'user_groups/customized', {
      user_group: user_group
    }
  end
end

if additions.include?('groups') || additions.include?('all')
  json.groups entity.authority_groups do |authority_group|
    json.partial! 'authority_groups/customized', {
      authority_group: authority_group
    }
  end
end

if additions.include?('degree') || additions.include?('all')
  json.degree entity.degree
end

if additions.include?('users') || additions.include?('all')
  if entity.creator_id && entity.creator
    json.creator do
      json.partial! 'users/customized', user: entity.creator
    end
  end

  if entity.updater_id && entity.updater
    json.updater do
      json.partial! 'users/customized', user: entity.updater
    end
  end
end

if additions.include?('fields') || additions.include?('all')
  json.fields entity.kind.field_instances(entity) do |field|
    json.partial! 'fields/customized', field: field
  end
end

if additions.include?('generators') || additions.include?('all')
  json.generators entity.kind.generators do |generator|
    json.partial! 'generators/customized', generator: generator
  end
end
