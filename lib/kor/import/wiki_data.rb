class Kor::Import::WikiData
  def initialize(data)
    @data = data
  end

  def self.find(qid)
    data = request(
      'get', "https://www.wikidata.org/wiki/Special:EntityData/#{qid}.json"
    )
    new(data['entities'].values.first)
  end

  def locale
    @locale || I18n.locale.to_s
  end

  attr_writer :locale

  def qid
    @data['id']
  end

  def label
    @data['labels'][locale]['value']
  end

  def description
    @data['descriptions'][locale]['value']
  end

  def aliases
    # TODO
  end

  def revision
    @data['lastrevid']
  end

  def entity
    @entity ||= Identifier.resolve(qid, 'wikidata_id')
  end

  def property_value(pid)
    @data["claims"][pid].first["mainsnak"]["datavalue"]["value"]
  end

  def properties
    @properties ||= begin
      results = []
      @data['claims'].each do |pid, claims|
        props = claims.select do |c|
          c['mainsnak']['datatype'] == 'wikibase-item' &&
            c['mainsnak']['snaktype'] == 'value' &&
            c['mainsnak']['datavalue']
        end

        if !props.empty?
          values = props.map do |i|
            if i['mainsnak']['datavalue']
              i['mainsnak']['datavalue']['value']['id']
            end
          end.compact
          results << {'id' => pid, 'values' => values}
        end
      end

      ids = results.map{ |r| r['id'] }
      labels = self.class.labels_for(ids, locale)
      results.each do |r|
        label = labels.find{ |l| l['id'] == r['id'] } || {'label' => 'related to'}
        r['label'] = label['label']
      end

      results
    end
  end

  def identifiers
    @identifiers ||= begin
      results = []
      self.class.identifier_types(locale).each do |i|
        if part = @data["claims"]["P#{i['id']}"]
          results << i.merge(
            'value' => part.first['mainsnak']['datavalue']['value']
          )
        end
      end
      results
    end
  end

  def entity_properties
    @entity_properties ||= properties.map do |r|
      values = r['values'].select{ |v| Identifier.resolve(v, 'wikidata_id') }
      r['values'] = values
      r
    end.reject{ |r| r['values'].empty? }
  end

  def import(user, collection, kind)
    entity = Entity.create(
      collection_id: collection.id,
      kind_id: kind.id,
      name: self.label,
      comment: self.description,
      dataset: {'wikidata_id' => qid},
      creator: user
    )

    update_relationships(entity)

    related_update

    entity
  end

  def update(entity, opts = {})
    opts.reverse_merge! attributes: false, recursive: true

    if opts[:attributes]
      entity.update(
        name: self.label,
        comment: self.description,
        dataset: entity.dataset.merge('wikidata_id' => qid)
      )
    end

    update_relationships(entity)

    # we also need to find all existing wikidata ids in the database and ask
    # for relationships to this entity from wikidata so we can update our
    # graph
    if opts[:recursive]
      related_update
    end
  end

  def related_update
    candidates = Identifier.where(kind: 'wikidata_id').pluck(:value).uniq
    self.class.related(qid, candidates).each do |other_qid|
      entity = Identifier.resolve(other_qid, 'wikidata_id')
      self.class.find(other_qid).update(entity, recursive: false)
    end
  end

  def update_relationships(entity)
    self.entity_properties.each do |r|
      targets = r['values'].map do |qid|
        Identifier.resolve(qid, 'wikidata_id')
      end

      targets.each do |target|
        # try normal direction
        attrs = {
          identifier: r['id'],
          from_kind_id: entity.kind_id,
          to_kind_id: target.kind_id
        }
        relation = Relation.find_by(attrs)

        # try reverse direction
        unless relation
          attrs = {
            reverse_identifier: r['id'],
            from_kind_id: entity.kind_id,
            to_kind_id: target.kind_id
          }
          relation = Relation.find_by(attrs)
        end

        # fall back to creating a new relation
        unless relation
          if Kor.settings['create_missing_relations']
            attrs.update(
              identifier: r['id'],
              reverse_identifier: "i#{r['id']}",
              name: r['label'],
              reverse_name: "inverse of '#{r['label']}'",
              from_kind_id: entity.kind_id,
              to_kind_id: target.kind_id
            )
            relation = Relation.create!(attrs)
          end
        end

        if relation
          attrs = {from_id: entity.id, to_id: target.id}
          Relationship.find_or_create_by!(attrs) do |rel|
            rel.relation_id = relation.id
          end
        end
      end
    end
  end

  def self.sparql(query)
    request 'get', 'https://query.wikidata.org/sparql', query: query
  end

  # retrieves items of type identifer (Q19595382, Q19847637 or Q18614948)
  def self.identifier_types(locale)
    query = "
      SELECT ?id ?label
      WHERE {
        ?id wdt:P31/wdt:P279* wd:Q19847637 .
        ?id rdfs:label ?label filter (lang(?label) = '#{locale}') .
      }
    "
    xml = sparql(query).body
    doc = Nokogiri::XML(xml)
    doc.xpath("//xmlns:result").map do |r|
      {
        "id" => r.xpath("xmlns:binding[@name='id']/xmlns:uri").text.split("/").last[1..-1],
        "label" => r.xpath("xmlns:binding[@name='label']/xmlns:literal").text
      }
    end
  end

  # finds all related item ids included within a set of candidates
  def self.related(target, candidates)
    candidates = candidates.map{ |c| "wd:#{c}" }.join(', ')
    query = "
      SELECT ?item ?rel
      WHERE
      {
        { ?item ?rel wd:#{target} } UNION
        { wd:Q5580 ?rel ?item }
        FILTER(?item IN (#{candidates}))
      }
    "
    xml = sparql(query).body
    doc = Nokogiri::XML(xml)

    uris = doc.xpath("//xmlns:result/xmlns:binding[@name='item']/xmlns:uri")
    uris.map{ |r| r.text.split('/').last }.uniq
  end

  def self.labels_for(ids, locale)
    values = ids.map{ |i| "(wd:#{i})" }.join(' ')
    query = "
      SELECT ?id $label
      WHERE {
         ?id rdfs:label ?label .
         FILTER(lang(?label) = '#{locale}')
      }
      VALUES (?id) {#{values}}
    "
    xml = sparql(query).body
    doc = Nokogiri::XML(xml)
    doc.xpath("//xmlns:result").map do |r|
      {
        "id" => r.xpath("xmlns:binding[@name='id']/xmlns:uri").text.split("/").last,
        "label" => r.xpath("xmlns:binding[@name='label']/xmlns:literal").text
      }
    end
  end

  def self.request(method, url, params = {}, body = nil, headers = {}, redirect_count = 10)
    @client ||= begin
      client = HTTPClient.new
      client.ssl_config.set_default_paths
      client
    end

    response = @client.request(method, url, params, headers, body)

    if redirect_count > 0 && response.redirect?
      response = request(
        method, response.http_header['location'].first,
        params, body, headers,
        redirect_count - 1
      )
    end

    if response.status != 200
      raise Kor::Exception, "wikidata returned status #{response.status}\n#{response.body}"
    end

    begin
      JSON.load(response.body)
    rescue JSON::ParserError
      response
    end
  end


  protected

    def id_for_entity(entity)
      entity.kind.fields.each do |f|
        f.entity = entity
        if f.wikidata_id && f.value
          response = find_by_attribute(f.wikidata_id, f.value)
          id = response["items"].first.to_s
          return id if id.present?
        end
      end

      nil
    end
end
