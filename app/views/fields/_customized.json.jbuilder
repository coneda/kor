additions ||= []

json.extract!(field,
  :type, :id, :name, :kind_id, :value, :is_identifier, :show_on_entity,
  :show_label, :form_label, :search_label, :errors
)

json.type field.class.name

if additions.include?('technical') || additions.include?('all')
  json.extract! field, :uuid, :created_at, :updated_at, :settings
end

if field.is_a?(Fields::Regex)
  json.extract! field, :regex
end
