json.total @total
json.per_page @per_page
json.page @page
json.records @records do |record|
  json.partial! 'credentials/customized', {
    credential: record,
    additions: inclusion
  }
end
