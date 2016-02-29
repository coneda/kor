json.message @notice
json.current_history do
  json.array! @current_history do |entity|
    json.partial! 'entities/minimal', entity: entity
  end
end
