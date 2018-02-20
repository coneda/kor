json.total @total
json.per_page @per_page
json.page @page

json.records @records do |record|
  json.partial! 'entities/customized', {
    entity: record,
    additions: inclusion,
    related_kind_id: params[:related_kind_id],
    related_relation_name: params[:related_relation_name],
    related_per_page: params[:related_per_page]
  }
end
