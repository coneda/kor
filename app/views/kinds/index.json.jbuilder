json.total = @kinds.count
json.page = 1
json.records do
  json.array! @kinds do |kind|
    json.partial! 'customized', {
      kind: kind,
      additions: params[:include]
    }
  end
end
