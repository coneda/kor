json.total @directed_relationships.count
json.records @directed_relationships.pageit(params[:page], params[:per_page]) do |directed_relationship|
  json.partial!('customized',
    directed_relationship: directed_relationship,
    additions: ['all']
  )
end