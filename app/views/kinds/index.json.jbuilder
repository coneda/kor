json.total @kinds.count
json.page params[:page] || 1

json.records @kinds do |kind|
  json.partial! 'customized', {
    kind: kind,
    additions: params[:include]
  }
end
