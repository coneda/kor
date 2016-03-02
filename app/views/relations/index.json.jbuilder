@relations.each do |relation_name, count|
  json.set! relation_name, count
end