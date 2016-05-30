json.ids @results.ids
json.total @results.total
json.records @results.records do |item|
  json.partial! 'entities/customized', entity: item, additions: params[:include]
end
