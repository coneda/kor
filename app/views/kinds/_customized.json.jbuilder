json.extract!(record,
  :schema,
  :id, :uuid, :url,
  :abstract,
  :name, :plural_name,
  :description
)

if inclusion.request?('settings')
  json.settings do
    json.name_label record.name_label
    json.tagging record.tagging
    json.dating_label record.dating_label
    json.distinct_name_label record.distinct_name_label
    json.requires_naming record.requires_naming?
    json.can_have_synonyms record.can_have_synonyms?
  end
end


if inclusion.request?('technical')
  json.uuid record.uuid
  json.created_at record.created_at
  json.updated_at record.updated_at
  json.lock_version record.lock_version
end

if inclusion.request?('fields')
  json.fields record.fields do |field|
    json.partial! 'fields/customized', field: field
  end
end

if inclusion.request?('generators')
  json.generators record.generators do |generator|
    json.partial! 'generators/customized', generator: generator
  end
end

if inclusion.request?('inheritance')
  json.extract! record, :parent_ids, :child_ids, :removable
end
