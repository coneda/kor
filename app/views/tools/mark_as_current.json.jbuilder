json.message @notice
json.current_history do
  json.array! @current_history do |entity|
    json.partial! 'entities/customized', entity: entity
  end
end
