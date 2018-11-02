json.cache! 'statistics', expires_in: 24.hours do
  json.timestamp Time.now.utc

  json.user_count User.without_predefined.count
  json.user_count_logged_in_recently User.without_predefined.logged_in_recently.count
  json.user_count_logged_in_last_year User.without_predefined.logged_in_last_year.count
  json.user_count_created_recently User.without_predefined.created_recently.count

  json.entity_count Entity.count
  by_kind = Entity.
    group("kind_id").
    count.
    sort{|x, y| y.last - x.last}.
    select{|stat| stat.last > 0}
  json.entities_by_kind by_kind do |stat|
    json.kind_name Kind.find(stat.first).name
    json.count stat.last
  end

  json.relationship_count Relationship.count
  by_relation = Relationship.
    group("relation_id").
    count.
    sort{|x, y| y.last - x.last}.
    select{|stat| stat.last > 0}
  json.relationships_by_relation by_relation do |stat|
    json.relation_name Relation.find(stat.first).name
    json.count stat.last
  end
end
