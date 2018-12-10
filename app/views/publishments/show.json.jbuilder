json.partial! 'customized', record: @publishment

json.entities @publishment.user_group.entities.each do |entity|
  json.partial! 'entities/customized', entity: entity
end
