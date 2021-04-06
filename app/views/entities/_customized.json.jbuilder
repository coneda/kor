json.extract!(entity,
  :id, :collection_id, :kind_id, :creator_id, :updater_id,
  :kind_name,
  :no_name_statement, :name, :distinct_name, :display_name,
  :comment, :subtype, :lock_version
)

json.tags(entity.tags.map{ |t| t.to_s })

if entity.is_medium?
  json.medium_id entity.medium_id

  json.medium do
    json.extract! entity.medium, :id, :file_size
    json.video entity.medium.video?
    json.audio entity.medium.audio?

    if allowed_to?(:download_originals, entity.collection)
      json.content_type entity.medium.content_type
    end

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
if allowed_to?(:view_meta, entity.collection) && inclusion.request?('technical')
  json.uuid entity.uuid
  json.created_at entity.created_at
  json.updated_at entity.updated_at
end

if inclusion.request?('synonyms')
  json.synonyms entity.synonyms
end

if inclusion.request?('datings')
  json.datings entity.datings do |dating|
    json.partial! 'datings/customized', record: dating
  end
end

if inclusion.request?('dataset')
  json.dataset entity.dataset
end

if inclusion.request?('properties')
  json.properties entity.properties
end

if inclusion.request?('relations')
  json.relations entity.relation_counts(current_user)
end

if inclusion.request?('media_relations')
  json.media_relations entity.relation_counts(current_user, media: true)
end

if inclusion.request?('related')
  directed_relationships = entity.outgoing_relationships.
    allowed(current_user).
    by_relation_name(related_relation_name).
    by_to_kind(related_kind_id).
    includes(to: [:tags, :collection, :kind, :medium]).
    pageit(1, related_per_page)

  json.related directed_relationships do |dr|
    json.partial! 'directed_relationships/customized', {
      record: dr,
      inclusion: ['to', 'properties']
    }
  end
end

if inclusion.request?('gallery_data')
  prs = entity.primary_relationships(current_user)
  json.primary_entities prs do |pr|
    json.partial! 'customized', entity: pr.to, inclusion: []

    srs = pr.to.secondary_relationships(current_user)
    json.secondary_entities srs do |sr|
      json.partial! 'customized', entity: sr.to, inclusion: []
    end
  end
end

if inclusion.request?('kind')
  json.kind do
    json.partial! 'kinds/customized', record: entity.kind, inclusion: ['settings']
  end
end

if inclusion.request?('collection')
  json.collection do
    json.partial! 'collections/customized', locals: {
      record: entity.collection
    }
  end
end

if inclusion.request?('user_groups')
  json.user_groups entity.user_groups.owned_by(current_user) do |user_group|
    json.partial! 'user_groups/customized', {
      record: user_group
    }
  end
end

if inclusion.request?('groups')
  json.groups entity.authority_groups do |authority_group|
    json.partial! 'authority_groups/customized', {
      record: authority_group
    }
  end
end

if inclusion.request?('degree')
  json.degree entity.degree
end

if inclusion.request?('users')
  if entity.creator_id && entity.creator
    json.creator do
      json.partial! 'users/customized', record: entity.creator
    end
  end

  if entity.updater_id && entity.updater
    json.updater do
      json.partial! 'users/customized', record: entity.updater
    end
  end
end

if inclusion.request?('fields')
  json.fields entity.kind.field_instances(entity) do |field|
    json.partial! 'fields/customized', record: field
  end
end

if inclusion.request?('generators')
  json.generators entity.kind.generators do |generator|
    json.partial! 'generators/customized', record: generator
  end
end
