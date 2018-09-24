json.total @total
json.per_page per_page
json.page page

# TODO: make all controllers use this
json.records @records do |record|
  json.partial! 'customized', {
    record: record,
    additions: inclusion
  }
end
