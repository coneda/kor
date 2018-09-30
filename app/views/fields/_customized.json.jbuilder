json.extract!(record,
  :type, :id, :name, :kind_id, :value, :is_identifier, :show_on_entity,
  :show_label, :form_label, :search_label, :errors
)

json.type record.class.name

if inclusion.request?('technical')
  json.extract! record, :uuid, :created_at, :updated_at, :settings
end

if record.is_a?(Fields::Regex)
  json.extract! record, :regex
end
