class Kor::NeoGraph

  def initialize(user, options = {})
    @user = user
    @options = Rails.configuration.database_configuration[Rails.env]['neo']
  end

  def reset!
    print [
      "You asked for a neo4j data reset. This is not possible in an efficient",
      "manner, please stop neo4j, delete its data directory and start neo4j",
      "again. Then hit enter."
    ].join(" ")
    x = STDIN.gets

    # cypher "MATCH (n) OPTIONAL MATCH (n)-[r]-() DELETE n,r"
    # cypher "MATCH ()-[r]-() DELETE r"
    # cypher "DROP INDEX ON :entity(id)"
    # cypher "DROP INDEX ON :entity(kind_id)"
  end

  def new_progress_bar(title, total)
    @progress = ProgressBar.create(
      :title => title,
      :total => total,
      :format => "%t: |%B|%a|%E|",
      :throttle_rate => 0.5
    )
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

  def import_all
    new_progress_bar "importing entities", Entity.count
    Entity.find_in_batches :batch_size => 100 do |batch|
      store(batch)
    end

    cypher "CREATE INDEX ON :entity(id)"
    cypher "CREATE INDEX ON :entity(kind_id)"

    new_progress_bar "importing relationships", Relationship.count
    Relationship.includes(:relation).find_in_batches :batch_size => 1000 do |batch|
      store(batch)
    end
  end

  def store(items)
    items = Kor.array_wrap(items)

    case items.first
      when Entity
        cypher(
          "statement" => "CREATE (n:entity {e}) RETURN n.id, id(n)",
          "parameters" => {
            "e" => items.map{ |item|
              increment
              {
                "id" => item.id,
                "uuid" => item.uuid,
                "collection_id" => item.collection_id,
                "name" => item.display_name,
                "distinct_name" => item.distinct_name || "",
                "subtype" => item.subtype || "",
                "medium_id" => item.medium_id || 0,
                "kind_id" => item.kind_id,
                "synonyms" => item.synonyms,
                "created_at" => item.created_at.to_f,
                "updated_at" => item.updated_at.to_f
              }
            }
          }  
        )
      when Relationship
        # TODO: add relationship datings
        statements = items.map do |item|
          {
            "statement" => [
              "MATCH (a:entity),(b:entity)",
              "WHERE a.id = {from_id} AND b.id = {to_id}",
              "CREATE (a)-[rn:`#{item.relation.name}` {data}]->(b)",
              "CREATE (b)-[rr:`#{item.relation.reverse_name}` {data}]->(a)"
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

        results = cypher(statements)
        increment items.size
      else
        raise "invalid items: #{items.inspect}"
    end
  end

  def cypher(statements = [])
    data = case statements
      when String then [{'statement' => statements}]
      when Hash then [statements]
      else
        statements
    end
    response = request "post", "/db/data/transaction/commit", {}, JSON.dump(
      "statements" => data
    )

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
      @client ||= HTTPClient.new
    end

    def request(method, path, params = {}, body = "", headers = {})
      headers.reverse_merge!(
        "Content-type" => "application/json",
        "Accept" => "application/json"
      )

      base_url = "http://#{@options['host']}:#{@options['port']}"
      client.request(method, "#{base_url}#{path}", params, body, headers)
    end

end