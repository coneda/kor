class Kor::Import::WikiData

  def find(id)
    request "get", "https://www.wikidata.org/wiki/Special:EntityData/Q#{id}.json"
  end

  def find_by_attribute(name, value)
    request "get", "https://wdq.wmflabs.org/api?q=STRING[#{name}:\"#{value}\"]"
  end

  def attribute_for(id, attribute)
    response = find(id)
    response["entities"]["Q#{id}"]["claims"]["P#{attribute}"].first["mainsnak"]["datavalue"]["value"]
  end

  def identifier_types
    query = "
      PREFIX wd: <http://www.wikidata.org/entity/> 
      PREFIX wdt: <http://www.wikidata.org/prop/direct/>
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

      SELECT ?id ?label
      WHERE {
        ?id wdt:P31 wd:Q19847637 . 
        ?id rdfs:label ?label filter (lang(?label) = 'en') .
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

  def identifiers_for(id)
    item = find(id)
    results = []
    identifier_types.each do |i|
      if part = item["entities"]["Q#{id}"]["claims"]["P#{i['id']}"]
        results << i.merge(
          "value" => part.first["mainsnak"]["datavalue"]["value"]
        )
      end
    end
    results
  end

  def sparql(query)
    request "get", "https://query.wikidata.org/sparql", :query => query
  end

  def request(method, url, params = {}, body = nil, headers = {})
    @client ||= HTTPClient.new

    response = @client.request(method, url, params, headers, body)

    begin
      Oj.load(response.body)
    rescue Oj::ParseError => e
      response
    end
  end

end