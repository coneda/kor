class Kor::Import::WikiData

  def initialize(locale = 'en')
    @locale = locale
  end

  def find(id)
    request "get", "https://www.wikidata.org/wiki/Special:EntityData/#{id}.json"
  end

  # def find_by_attribute(name, value)
  #   request "get", "https://wdq.wmflabs.org/api?q=STRING[#{name}:\"#{value}\"]"
  # end

  def attribute_for(id, attribute)
    response = find(id)
    response["entities"][id]["claims"][attribute].first["mainsnak"]["datavalue"]["value"]
  end

  def identifier_types
    query = "
      PREFIX wd: <http://www.wikidata.org/entity/> 
      PREFIX wdt: <http://www.wikidata.org/prop/direct/>
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

      SELECT ?id ?label
      WHERE {
        {?id wdt:P31 wd:Q19595382} UNION
        {?id wdt:P31 wd:Q19847637} UNION
        {?id wdt:P31 wd:Q18614948}.
        ?id rdfs:label ?label filter (lang(?label) = '#{@locale}') .
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

  def labels_for(ids)
    values = ids.map{|i| "(wd:#{i})"}.join(' ')
    query = "
      PREFIX wd: <http://www.wikidata.org/entity/> 
      PREFIX wdt: <http://www.wikidata.org/prop/direct/>
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

      SELECT ?id $label
      WHERE {
         ?id rdfs:label ?label .
         FILTER(lang(?label) = '#{@locale}')
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

  def identifiers_for(id)
    item = find(id)
    results = []
    identifier_types.each do |i|
      if part = item["entities"][id]["claims"]["P#{i['id']}"]
        results << i.merge(
          'value' => part.first['mainsnak']['datavalue']['value']
        )
      end
    end
    results
  end

  def internal_properties_for(item)
    item = find(item) if item.is_a?(String)

    results = []
    item['entities'].values.first['claims'].each do |pid, claims|
      internal = claims.select{|c| c['mainsnak']['datatype'] == 'wikibase-item'}

      if !internal.empty?
        values = internal.map{|i| i['mainsnak']['datavalue']['value']['id']}
        results << {'id' => pid, 'values' => values}
      end
    end

    ids = results.map{|r| r['id']}
    labels = labels_for(ids)
    results.each do |r|
      r['label'] = labels.find{|l| l['id'] == r['id']}['label']
    end

    results
  end

  def sparql(query)
    request "get", "https://query.wikidata.org/sparql", :query => query
  end

  def preflight(user, collection, id, kind)
    entity = Identifier.resolve(id, 'wikidata_id')
    collection = user.authorized_collections(:create).find_by(name: collection)
    kind = Kind.find_by(name: kind)

    # unless kind
    #   results = {
    #     'success' => false,
    #     'message' => 'kind not found'
    #   }
    # end

    item = find(id)
    label = item['entities'][id]['labels'][@locale]['value']
    rels = internal_properties_for(item).map do |r|
      values = r['values'].select{|v| Identifier.resolve(v, 'wikidata_id')}
      r['values'] = values
      r
    end.reject{|r| r['values'].empty?}

    results = {
      'success' => true,
      'message' => 'item can be imported',
      'entity' => {
        'collection_id' => collection.id,
        'kind_id' => kind.id,
        'id' => (entity ? entity.id : nil),
        'name' => label,
        'dataset' => {'wikidata_id' => id}
      },
      'relationships' => rels
    }

    results
  end

  def import(user, collection, id, kind)
    pd = preflight(user, collection, id, kind)
    if pd['success']
      entity = Entity.create(pd['entity'])
      rels = []
      pd['relationships'].each do |r|
        targets = {}
        r['values'].each{|v| targets[v] = Identifier.resolve(v, 'wikidata_id')}

        targets.each do |id, target|
          relation = Relation.find_or_create_by!(
            name: r['label'],
            reverse_name: "inverse of '#{r['label']}'",
            from_kind_id: entity.kind_id,
            to_kind_id: target.kind_id
          )

          rels << Relationship.find_or_create_by(from_id: entity.id, to_id: target.id) do |r|
            r.relation_id = relation.id
          end
        end
      end
      pd['message'] = 'item has been imported'
      pd['entity'].merge!(
        'id' => entity.id,
        'uuid' => entity.uuid
      )
      pd['relationships'] = rels.map do |r|
        {
          'id' => r.id,
          'from_id' => r.from_id,
          'to_id' => r.to_id,
          'relation_id' => r.relation_id
        }
      end
    end
    pd
  end

  protected

    def request(method, url, params = {}, body = nil, headers = {}, redirect_count = 10)
      @client ||= HTTPClient.new

      response = @client.request(method, url, params, headers, body)

      if redirect_count > 0 && response.redirect?
        response = request(
          method, response.http_header['location'].first,
          params, body, headers,
          redirect_count - 1
        )
      end

      begin
        JSON.load(response.body)
      rescue JSON::ParserError => e
        response
      end
    end

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