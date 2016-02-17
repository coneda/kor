json.array! @directed_relationships do |directed_relationship|
  json.partial! 'extended', directed_relationship: directed_relationship
end