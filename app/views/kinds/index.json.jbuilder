json.total @total
json.page @page
json.per_page @per_page
json.records @records do |record|
  json.partial! 'kinds/customized', {
    kind: record,
    additions: params[:include]
  }
end
