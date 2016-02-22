json.merge! @entity.serializable_hash(
  :include => [:kind, :collection, :datings, :creator, :updater, :authority_groups],
  :methods => [:synonyms, :dataset, :degree, :properties, :display_name],
  :root => false
)

if @entity.is_medium?
  json.medium do
    json.partial! 'media/minimal', medium: @entity.medium
  end
end

json.fields @entity.kind.field_instances(@entity).map{|f| f.serializable_hash}
json.tags @entity.tag_list.join(', ')
json.generators @entity.kind.generators.map{|g| g.serializable_hash}
      
json.relation_counts @entity.relation_counts(current_user)
json.media_relation_counts @entity.relation_counts(current_user, media: true)
