class Kor::Import::ErlangenCrm
  def run
    Relation.transaction do
      Kind.transaction do
        process
        raise ActiveRecord::Rollback
      end
    end
  end

  def process
    doc = crm
    parent_map = {}
    doc.xpath('/rdf:RDF/owl:Class').each do |klass|
      kind = Kind.create(
        schema: 'Erlangen CRM',
        url: klass['rdf:about'],
        name: klass.xpath('rdfs:label').text,
        plural_name: klass.xpath('rdfs:label').text.gsub(/E\d+\s/, '').pluralize,
        description: (
          "#{klass.xpath('rdfs:label').text}\n\n#{klass.xpath('rdfs:comment').text}"
        ),
        abstract: true,
        uuid: uuid_mapping[klass['rdf:about']]
      )

      unless kind.valid?
        p kind.errors.full_messages
        binding.pry
      end

      if parent = klass.xpath('rdfs:subClassOf/owl:Class').first
        parent_map[kind.url] ||= []
        parent_map[kind.url] << parent['rdf:about']
      end

      klass.xpath('rdfs:subClassOf[@rdf:resource]/@rdf:resource').each do |p|
        parent_map[kind.url] ||= []
        parent_map[kind.url] << p.text
      end
    end

    parent_map.each do |child_url, parent_urls|
      parent_urls.each do |parent_url|
        if parent = Kind.where(url: parent_url).first && child = Kind.where(url: child_url).first
          parent.children << child
        end
      end
    end

    @lookup = {}
    properties.each do |property|
      begin
        url = property['rdf:about']
        @lookup[url] = {
          type: property.name,
          url: url,
          name: property.xpath('rdfs:label').text,
          reverse_url: property.xpath('owl:inverseOf/*').map{ |r| r['rdf:about'] }.first,
          parent_urls: property.xpath('rdfs:subPropertyOf/*').map{ |sp| sp['rdf:about'] },
          from_urls: property.xpath('rdfs:domain').map{ |d| d['rdf:resource'] },
          to_urls: property.xpath('rdfs:range').map{ |d| d['rdf:resource'] },
          description: property.xpath('rdfs:comment').text
        }
      rescue => e
        puts e.message
        puts e.backtrace
        binding.pry
      end
    end

    @lookup.each do |url, r|
      if r[:reverse_url] && !@lookup[r[:reverse_url]][:reverse_url]
        @lookup[r[:reverse_url]][:reverse_url] = url
      end

      if r[:type] == 'SymmetricProperty'
        r[:reverse_url] = url
      end
    end

    done = {}
    relations = []
    @lookup.each do |url, r|
      if !done[url] && !done[r[:reverse_url]]
        done[url] = true
        done[r[:reverse_url]] = true

        if r[:reverse_url] && r[:name].present?
          froms = Kind.where(url: from_urls_for(r)).pluck(:id)
          tos = Kind.where(url: to_urls_for(r)).pluck(:id)

          froms.product(tos).each do |c|
            relation = Relation.create(
              schema: 'Erlangen CRM',
              url: url,
              name: r[:name],
              reverse_name: @lookup[r[:reverse_url]][:name],
              from_kind_id: c[0],
              to_kind_id: c[1],
              description: r[:description],
              abstract: true,
              uuid: uuid_mapping[url]
            )
            relation.save!
            relations << relation
          end
        end
      end
    end

    Relation.all.each do |relation|
      if relation.url && r = @lookup[relation.url] && r[:parent_urls].present?
        relation.update_attributes(
          parent_ids: Relation.where(url: r[:parent_urls]).pluck(:id)
        )
      end
    end
  end

  protected

    def properties
      conds = [
        "self::owl:ObjectProperty",
        "self::owl:TransitiveProperty",
        "self::owl:SymmetricProperty",
        # "self::owl:DatatypeProperty",
        "self::owl:FunctionalProperty",
        "self::owl:InverseFunctionalProperty"
      ].join(' or ')
      crm.xpath("/rdf:RDF/*[#{conds}]")
    end

    def crm
      @crm ||= begin
        url = 'http://erlangen-crm.org/ontology/ecrm/ecrm_current.owl'
        response = HTTPClient.new.get(url)
        if response.status == 200
          Nokogiri::XML(response.body)
        else
          raise "request failed: GET #{url} (#{response.status} #{response.body})"
        end
      end
    end

    def uuid_mapping
      @uuid_mapping ||= JSON.load(File.read "#{Rails.root}/public/schema/crm_to_uuid_map.json")
    end

    def from_urls_for(r)
      return [] unless r

      ([r[:from_urls]] + r[:parent_urls]).map{ |pu| from_urls_for(@lookup[pu]) }.flatten
    end

    def to_urls_for(r)
      return [] unless r

      ([r[:to_urls]] + r[:parent_urls]).map{ |pu| to_urls_for(@lookup[pu]) }.flatten
    end
end
