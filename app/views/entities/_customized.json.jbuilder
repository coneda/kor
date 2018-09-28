additions ||= []

json.extract!(entity,
  :id, :collection_id, :kind_id, :creator_id, :updater_id,
  :kind_name,
  :name, :distinct_name, :display_name,
  :comment, :subtype
)

json.tags entity.tags.map{|t| t.to_s}

if entity.is_medium?
  json.medium_id entity.medium_id

  json.medium do
    json.extract! entity.medium, :id, :file_size, :content_type
    json.video entity.medium.video?
    json.audio entity.medium.audio?

    json.url do
      json.icon entity.medium.url(:icon)
      json.thumbnail entity.medium.url(:thumbnail)
      json.preview entity.medium.url(:preview)
      json.screen entity.medium.url(:screen)
      json.normal entity.medium.url(:normal)
      json.original entity.medium.url(:original)

      if entity.medium.video?
        json.set! 'video/mp4', entity.medium.document.url(:mp4)
        json.set! 'video/webm', entity.medium.document.url(:webm)
        json.set! 'video/ogg', entity.medium.document.url(:ogg)
      end

      if entity.medium.audio?
        json.set! 'audio/mp3', entity.medium.document.url(:mp3)
        json.set! 'audio/ogg', entity.medium.document.url(:ogg)
      end
    end
  end
end

# TODO: this should also be possible with edit rights and delete/create rights,
# e.g. for merging
if authorized?(:view_meta, entity.collection)
  if additions.request?('technical')
    json.uuid entity.uuid
    json.created_at entity.created_at
    json.updated_at entity.updated_at
    json.no_name_statement entity.no_name_statement
  end
end

if additions.request?('synonyms')
  json.synonyms entity.synonyms
end

if additions.request?('datings')
  json.datings entity.datings do |dating|
    json.partial! 'datings/customized', dating: dating
  end
end

if additions.request?('dataset')
  json.dataset entity.dataset
end

if additions.request?('properties')
  json.properties entity.properties  
end

if additions.request?('relations')
  json.relations entity.relation_counts(current_user)
end

if additions.request?('media_relations')
  json.media_relations entity.relation_counts(current_user, media: true)
end

if additions.request?('related')
  directed_relationships = entity.outgoing_relationships.
    allowed(current_user).
    by_relation_name(related_relation_name).
    by_to_kind(related_kind_id).
    includes(to: [:tags, :collection, :kind, :medium]).
    pageit(1, related_per_page)

  json.related directed_relationships do |dr|
    json.partial! 'directed_relationships/customized', {
      directed_relationship: dr,
      additions: ['to', 'properties']
    }
  end
end

if additions.request?('gallery_data')
  ors = entity.
    outgoing_relationships.
    allowed(current_user).
    by_relation_name(Relation.primary_relation_names).
    includes(to: [:tags, :collection, :kind, :medium])

  json.primary_entities ors do |pr|
    json.partial! 'customized', entity: pr.to

    ors = pr.to.
      outgoing_relationships.
      allowed(current_user).
      by_relation_name(Relation.secondary_relation_names).
      includes(to: [:tags, :collection, :kind, :medium])

    json.secondary_entities ors do |sr|
      json.partial! 'customized', entity: sr.to
    end
  end
end

if additions.request?('kind')
  json.kind do
    json.partial! 'kinds/customized', kind: entity.kind, additions: ['settings']
  end
end

if additions.request?('collection')
  json.collection do
    json.partial! 'collections/customized', locals: {
      kor_collection: entity.collection
    }
  end
end

if additions.request?('user_groups')
  json.user_groups entity.user_groups.owned_by(current_user) do |user_group|
    json.partial! 'user_groups/customized', {
      user_group: user_group
    }
  end
end

if additions.request?('groups')
  json.groups entity.authority_groups do |authority_group|
    json.partial! 'authority_groups/customized', {
      record: authority_group
    }
  end
end

if additions.request?('degree')
  json.degree entity.degree
end

if additions.request?('users')
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

if additions.request?('fields')
  json.fields entity.kind.field_instances(entity) do |field|
    json.partial! 'fields/customized', field: field
  end
end

if additions.request?('generators')
  json.generators entity.kind.generators do |generator|
    json.partial! 'generators/customized', generator: generator
  end
end
