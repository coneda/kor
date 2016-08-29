json.array! @collections do |item|
  json.partial! 'customized', kor_collection: item, additions: 'all'
end