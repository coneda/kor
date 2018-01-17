json.total @kinds.count
json.records @kinds.to_a do |item|
  json.partial! 'kinds/customized', {
    kind: item,
    additions: params[:include],
  }
end
