json.extract! record, :id, :name

if inclusion.include?('ancestry')
  json.ancestors record.self_and_ancestors do |ancestor|
    json.partial! 'customized', record: ancestor, inclusion: []
  end
end

if inclusion.include?('technical') || inclusion.include?('all')
  json.extract! record, :created_at, :updated_at
end