json.ids @results.ids
json.total @results.total
json.records @results.records do |item|
  json.partial! 'entities/customized', {
    entity: item,
    additions: params[:include],
    related_kind_id: params[:related_kind_id],
    related_relation_name: params[:related_relation_name],
    related_per_page: params[:related_per_page]
  }
end
