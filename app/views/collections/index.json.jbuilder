json.total @total
json.per_page @per_page
json.page @page

json.records @records do |record|
  json.partial! 'collections/customized', {
    kor_collection: record,
    additions: inclusion
  }
end
