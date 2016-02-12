json.total @result.total
json.page @result.page
json.per_page @result.per_page
json.total_pages @result.total_pages

json.records do
  json.array! @result.records do |entity|
    json.partial! 'entity_minimal', entity: entity

    ors = entity.
      outgoing_relationships.
      by_name(Relation.primary_relation_names).
      includes(:to)

    json.primary_entities ors do |pr|
      json.partial! 'entity_minimal', entity: pr.to

      ors = pr.to.
        outgoing_relationships.
        by_name(Relation.secondary_relation_names).
        includes(:to)

      json.secondary_entities ors do |sr|
        json.partial! 'entity_minimal', entity: sr.to
      end
    end
  end
end