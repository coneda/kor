additions ||= []

json.extract!(kind,
  :schema,
  :id, :uuid, :url,
  :abstract,
  :name, :plural_name,
  :description
)

if additions.request?('settings')
  json.settings do
    json.name_label kind.name_label
    json.tagging kind.tagging
    json.dating_label kind.dating_label
    json.distinct_name_label kind.distinct_name_label
    json.requires_naming kind.requires_naming?
    json.can_have_synonyms kind.can_have_synonyms?
  end
end

if additions.request?('fields')
  json.fields kind.fields do |field|
    json.partial! 'fields/customized', field: field
  end
end

if additions.request?('generators')
  json.fields kind.generators do |generator|
    json.partial! 'generators/customized', generator: generator
  end
end

if additions.request?('technical')
  json.uuid kind.uuid
  json.created_at kind.created_at
  json.updated_at kind.updated_at
  json.lock_version kind.lock_version
end

if additions.request?('fields')
  json.fields kind.fields do |field|
    json.partial! 'fields/customized', additions: additions, field: field
  end
end

if additions.request?('generators')
  json.generators kind.generators do |generator|
    json.partial! 'generators/customized', additions: additions, generator: generator
  end
end

if additions.request?('inheritance')
  json.extract! kind, :parent_ids, :child_ids, :removable
end
