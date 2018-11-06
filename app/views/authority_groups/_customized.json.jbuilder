json.extract! record, :id, :name, :authority_group_category_id

if inclusion.request?('technical')
  json.extract! record, :uuid, :lock_version, :created_at, :updated_at
end

if inclusion.request?('directory')
  if record.authority_group_category
    json.directory do
      json.partial! 'authority_group_categories/customized', {
        record: record.authority_group_category,
        inclusion: ['ancestors']
      }
    end
  end
end
