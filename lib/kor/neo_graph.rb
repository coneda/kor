class Kor::NeoGraph

  def initialize(user, options = {})
    @user = user
    @options = Rails.configuration.database_configuration[Rails.env]['neo']
    @transactions = []
  end

  def reset!
    while node_count > 0
      cypher "MATCH (n) WITH n LIMIT 1000 DETACH DELETE n"
    end

    # print [
    #   "You asked for a neo4j data reset. This is not possible in an efficient",
    #   "manner, please stop neo4j, delete its data directory and start neo4j",
    #   "again. Then hit enter."
    # ].join(" ")
    # x = STDIN.gets

    # cypher "MATCH (n) OPTIONAL MATCH (n)-[r]-() DELETE n,r"
    # cypher "MATCH ()-[r]-() DELETE r"
    # cypher "DROP INDEX ON :entity(id)"
    # cypher "DROP INDEX ON :entity(kind_id)"
  end

  def transaction(&block)
    response = request "post", "/db/data/transaction"
    @transactions.push JSON.parse(response.body)
    yield
    id = @transactions.pop['commit'].split('/')[-2]
    response = request "delete", "/db/data/transaction/#{id}"
  end

  def new_progress_bar(title, total)
    @progress = Kor.progress_bar(title, total)
  end

  def increment(i = 1)
    if @progress
      if i == 1
        @progress.increment
      else
        @progress.progress += i
      end
    end
  end

  def connect_random
    100.times do
      max = Entity.count
      from = Entity.offset((max * rand).to_i).first.id
      to = Entity.offset((max * rand).to_i).first.id

      results = cypher("MATCH (a),(b), p = shortestPath((a)-[r*..25]->(b)) WHERE a.id = #{from} AND b.id = #{to} RETURN nodes(p), [r IN relationships(p) | type(r)]")

      if results["results"].first["data"].empty?
        puts "!!!#{from} -> #{to}: no connection"
      else
        nodes = results["results"].first["data"].first["row"].first
        rels = results["results"].first["data"].first["row"].last
        puts nodes.first["name"]
        rels.each_with_index do |r, i|
          puts r
          puts "  [#{nodes[i + 1]['id']}] #{nodes[i + 1]["name"]}"
        end
      end
      puts
    end
  end

  def node_count
    response = cypher('MATCH (n) RETURN count(*)')
    response['results'].first['data'].first['row'].first
  end

  def import_all
    new_progress_bar "importing entities", Entity.count
    Entity.includes(:kind).find_in_batches :batch_size => 100 do |batch|
      store_entity(batch)
      increment(batch.size)
    end
    
    cypher "CREATE INDEX ON :entity(id)"
    cypher "CREATE INDEX ON :entity(kind_id)"
    cypher "CREATE INDEX ON :entity(kind_name)"
    cypher "CREATE INDEX ON :group(name)"

    new_progress_bar "importing groups", AuthorityGroup.count
    AuthorityGroup.includes(:entities).find_in_batches :batch_size => 10 do |batch|
      store_group(batch)
      increment(batch.size)
    end

    new_progress_bar "importing relationships", Relationship.count
    Relationship.includes(:relation).find_in_batches :batch_size => 1000 do |batch|
      store_relationship(batch)
      increment(batch.size)
    end
  end

  def store_entity(entity)
    entity = [entity] unless entity.is_a?(Array)
    cypher(
      "statement" => "UNWIND $props AS map CREATE (n:entity) SET n = map",
      "parameters" => {
        "props" => entity.map{ |item|
          data = {
            "id" => item.id,
            "uuid" => item.uuid,
            "collection_id" => item.collection_id,
            "name" => item.display_name,
            "distinct_name" => item.distinct_name || "",
            "subtype" => item.subtype || "",
            "medium_id" => item.medium_id || 0,
            "kind_id" => item.kind_id,
            'kind' => item.kind.name,
            "synonyms" => item.synonyms,
            "created_at" => item.created_at.to_f,
            "updated_at" => item.updated_at.to_f
          }
        }
      }  
    )
  end

  def store_group(group)
    group = [group] unless group.is_a?(Array)
    cypher(
      "statement" => "UNWIND $props AS map CREATE (n:group) SET n = map",
      "parameters" => {
        "props" => group.map{ |item|
          data = {
            'id' => item.id,
            'uuid' => item.uuid,
            'name' => item.name,
            'created_at' => item.created_at.to_f,
            'updated_at' => item.updated_at.to_f,
            'authority_group_category_id' => item.authority_group_category_id
          }
        }
      }  
    )

    group.each do |g|
      g.entities.select(:id).find_in_batches batch_size: 100 do |batch|
        statements = batch.map{|e|
          data = {
            "statement" => [
              "MATCH (a:entity),(b:group)",
              "WHERE a.id = $entity_id AND b.id = $group_id",
              "CREATE (a)-[rn:`is in`]->(b)",
              "CREATE (b)-[rr:`contains`]->(a)"
            ].join(" "),
            "parameters" => {
              "entity_id" => e.id,
              "group_id" => g.id
            }
          }
        }
        cypher(statements)
      end
    end
  end

  def store_relationship(relationship)
    relationship = [relationship] unless relationship.is_a?(Array)
    statements = relationship.map do |item|
      {
        "statement" => [
          "MATCH (a:entity),(b:entity)",
          "WHERE a.id = $from_id AND b.id = $to_id",
          "CREATE (a)-[rn:`#{item.relation.name}` $data]->(b)",
          "CREATE (b)-[rr:`#{item.relation.reverse_name}` $data]->(a)"
        ].join(" "),
        "parameters" => {
          "from_id" => item.from_id,
          "to_id" => item.to_id,
          "data" => {
            "id" => item.id,
            "uuid" => item.uuid,
            "relation_name" => item.relation.name,
            "relation_reverse_name" => item.relation.reverse_name,
            "created_at" => item.created_at.to_f,
            "updated_at" => item.updated_at.to_f    
          }
        }
      }
    end
    cypher(statements)
  end

  def cypher(statements = [])
    data = case statements
      when String then [{'statement' => statements}]
      when Hash then [statements]
      else
        statements
    end

    path = if @transactions.present?
      id = @transactions.last['commit'].split('/')[-2]
      "/db/data/transaction/#{id}"
    else
      '/db/data/transaction/commit'
    end

    response = request "post", path, {}, JSON.dump("statements" => data)

    if response.ok?
      data = JSON.parse(response.body)

      if data["errors"].empty?
        data
      else
        binding.pry
        data
      end
    else
      puts response.body, response.status
      nil
    end    
  end

  protected

    def client
      @client ||= begin
        c = HTTPClient.new
        c.set_auth(
          "http://#{@options['host']}:#{@options['port']}",
          @options['username'],
          @options['password']
        )
        c
      end
    end

    def request(method, path, params = {}, body = "", headers = {})
      headers.reverse_merge!(
        "Content-type" => "application/json",
        "Accept" => "application/json"
      )

      base_url = "http://#{@options['host']}:#{@options['port']}"
        # p [method, "#{base_url}#{path}", params, body, headers]
      client.request(method, "#{base_url}#{path}", params, body, headers)
    end

end