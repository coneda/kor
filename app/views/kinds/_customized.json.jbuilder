additions ||= []

json.extract!(kind,
  :id, :url,
  :abstract,
  :name, :plural_name,
  :description,
  :parent_ids,
  :child_ids
)

if additions.include?('settings') || additions.include?('all')
  json.name_label kind.name_label
  json.tagging kind.tagging
  json.dating_label kind.dating_label
  json.distinct_name_label kind.distinct_name_label
  json.requires_naming kind.requires_naming?
  json.can_have_synonyms kind.can_have_synonyms?
end

if additions.include?('technical') || additions.include?('all')
  json.uuid kind.uuid
  json.created_at kind.created_at
  json.updated_at kind.updated_at
  json.lock_version kind.lock_version
end

if additions.include?('fields') || additions.include?('all')
  json.fields kind.fields do |field|
    json.partial! 'fields/customized', additions: additions, field: field
  end
end

if additions.include?('generators') || additions.include?('all')
  json.fields kind.generators do |generator|
    json.partial! 'generators/customized', additions: additions, generator: generator
  end
end

if additions.include?('ancestry') || additions.include?('all')
  json.parents kind.parents do |parent|
    json.partial! 'kinds/customized', additions: additions, kind: parent
  end
end