json.total @total
json.per_page @per_page
json.page @page
json.records @records do |item|
  json.partial! 'users/customized', {
    user: item,
    additions: inclusion
  }
end
