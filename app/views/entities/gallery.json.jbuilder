json.total @total
json.page @page
json.per_page @per_page

json.records @records do |record|
  json.partial! 'customized', entity: record

  ors = record.
    outgoing_relationships.
    by_relation_name(Relation.primary_relation_names).
    includes(:to)

  json.primary_entities ors do |pr|
    json.partial! 'customized', entity: pr.to

    ors = pr.to.
      outgoing_relationships.
      by_relation_name(Relation.secondary_relation_names).
      includes(:to)

    json.secondary_entities ors do |sr|
      json.partial! 'customized', entity: sr.to
    end
  end
end