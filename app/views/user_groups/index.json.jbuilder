json.total @total
json.per_page @per_page
json.page @page

json.records @records do |record|
  json.partial! 'customized', {
    user_group: record,
    additions: inclusion
  }
end
