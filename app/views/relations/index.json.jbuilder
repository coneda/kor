json.total @records.count
json.page 1
json.per_page @records.count

json.records @records do |relation|
  json.partial! 'customized', relation: relation, additions: params[:include]
end
