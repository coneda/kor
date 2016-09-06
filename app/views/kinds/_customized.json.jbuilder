additions ||= []

json.extract!(kind,
  :id,
  :parent_id, :lft, :rgt, :abstract, :children_count,
  :name, :plural_name,
  :description
)

if additions.include?('settings') || additions.include?('all')
  json.settings do
    json.merge! kind.settings
    json.name_label kind.name_label
    json.tagging kind.tagging
    json.dating_label kind.dating_label
    json.distinct_name_label kind.distinct_name_label
    json.requires_naming kind.requires_naming?
    json.can_have_synonyms kind.can_have_synonyms?
  end
end

if additions.include?('technical') || additions.include?('all')
  json.uuid kind.uuid
  json.created_at kind.created_at
  json.updated_at kind.updated_at
  json.lock_version kind.lock_version
end

if additions.include?('children') || additions.include?('all')
  json.children do
    json.array! kind.children do |child|
      json.partial! 'customized', kind: child, additions: additions
    end
  end
end