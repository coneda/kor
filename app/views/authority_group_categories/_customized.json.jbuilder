json.extract! record, :id, :name, :parent_id, :lft, :rgt

if inclusion.include?('ancestors') || inclusion.include?('all')
  json.ancestors record.ancestors do |ancestor|
    json.partial! 'authority_group_categories/customized', record: ancestor, inclusion: []
  end
end

if inclusion.include?('technical') || inclusion.include?('all')
  json.extract! record, :created_at, :updated_at
end
