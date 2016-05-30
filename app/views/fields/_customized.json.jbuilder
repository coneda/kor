additions ||= []

json.id field.id
json.name field.name
json.kind_id field.kind_id
json.value field.value
json.is_identifier field.is_identifier
json.show_on_entity field.show_on_entity

json.show_label field.show_label
json.form_label field.form_label
json.search_label field.search_label

if additions.include?('technical') || additions.include?('all')
  json.uuid field.uuid
  json.created_at field.created_at
  json.updated_at field.updated_at
  json.settings field.settings
end
