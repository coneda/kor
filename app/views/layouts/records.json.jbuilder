json.total @total
json.per_page @per_page
json.page @page

json.records @collection do |record|
  json.partial! 'customized', {
    kor_collection: record,
    additions: inclusion
  }
end
