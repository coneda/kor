class Kor::NeoGraph

  def initialize(user, options = {})
    @user = user
    @options = options.reverse_merge(
      :base_dir => "/opt/neo4j-community-2.1.4",
      :base_url => "http://localhost:7474"
    )
    @entities_done = {}
  end

  def reset!
    commit "MATCH ()-[r]-() DELETE r"
    commit "MATCH (n) OPTIONAL MATCH (n)-[r]-() DELETE n,r"
    commit "DROP INDEX ON :entity(id)"
    commit "DROP INDEX ON :entity(kind_id)"
  end

  def store(item)
    case item
      when Entity

      when Relationship
      when Relation
    end
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
    if i == 1
      @progress.increment
    else
      @progress.progress += i
    end
  end

  def connect_random
    max = Entity.count
    from = Entity.offset((max * rand).to_i).first.id
    to = Entity.offset((max * rand).to_i).first.id
    results = simple_cypher("MATCH (a),(b), p = shortestPath((a)-[r*..25]->(b)) WHERE a.id = #{from} AND b.id = #{to} RETURN nodes(p), [r IN relationships(p) | type(r)]")

    if results["results"].first["data"].empty?
      puts "no connection"
    else
      nodes = results["results"].first["data"].first["row"].first
      rels = results["results"].first["data"].first["row"].last
      puts nodes.first["name"]
      rels.each_with_index do |r, i|
        puts r
        puts nodes[i + 1]["name"]
      end
    end
  end

  def create_all
    # new_progress_bar "importing entities", Entity.count
    # Entity.find_in_batches :batch_size => 100 do |batch|
    #   results = cypher(
    #     "statement" => "CREATE (n:entity {e}) RETURN n.id, id(n)",
    #     "parameters" => {
    #       "e" => batch.map{|item|
    #         {
    #           "id" => item.id,
    #           "uuid" => item.uuid,
    #           "collection_id" => item.collection_id,
    #           "name" => item.display_name,
    #           "distinct_name" => item.distinct_name,
    #           "kind_id" => item.kind_id,
    #           "subtype" => item.subtype,
    #           "synonyms" => item.synonyms,
    #           "medium_id" => item.medium_id,
    #           "created_at" => item.created_at.to_f,
    #           "updated_at" => item.updated_at.to_f
    #         }
    #       }
    #     }  
    #   )
    # end

    # commit "CREATE INDEX ON :entity(id)"
    # commit "CREATE INDEX ON :entity(kind_id)"

    new_progress_bar "importing relationships", Relationship.count
    Relationship.includes(:relation).find_in_batches :batch_size => 1000 do |batch|
      statements = batch.map do |relationship|
        {
          "statement" => [
            "MATCH (a:entity),(b:entity)",
            "WHERE a.id = {from_id} AND b.id = {to_id}",
            "CREATE (a)-[rn:`#{relationship.relation.name}` {data}]->(b)",
            "CREATE (b)-[rr:`#{relationship.relation.reverse_name}` {data}]->(a)"
          ].join(" "),
          "parameters" => {
            "from_id" => relationship.from_id,
            "to_id" => relationship.to_id,
            "data" => {
              "id" => relationship.id,
              "uuid" => relationship.uuid,
              "relation_name" => relationship.relation.name,
              "relation_reverse_name" => relationship.relation.reverse_name,
              "created_at" => relationship.created_at.to_f,
              "updated_at" => relationship.updated_at.to_f    
            }
          }
        }
      end

      results = cypher(statements)
      increment batch.size
    end
  end

  # def create(item, bulk = false)
  #   case item
  #     when Array
  #       data = item.map{|i| create(i, true)}
  #       # response = request "post", "/db/data/batch", {}, data.to_json
  #       # if response.ok?
  #       #   Oj.load response.body
  #       # else
  #       #   binding.pry
  #       #   x = 12
  #       # end
  #     when Entity
  #       data = {
  #         "id" => item.id,
  #         "uuid" => item.uuid,
  #         "collection_id" => item.collection_id,
  #         "name" => item.display_name,
  #         "distinct_name" => item.distinct_name,
  #         "kind_id" => item.kind_id,
  #         "subtype" => item.subtype,
  #         "synonyms" => item.synonyms,
  #         "medium_id" => item.medium_id,
  #         "created_at" => item.created_at.to_f,
  #         "updated_at" => item.updated_at.to_f
  #       }

  #       data.each do |k, v|
  #         data.delete(k) if v.blank?
  #       end

  #       if bulk
  #         data
  #         # {"to" => "/node", "method" => "post", "body" => , "labels" => ["entity"]}
  #       else
  #         response = request "post", "/db/data/node", {}, data.to_json
  #         if response.ok?
  #           response.headers["Location"].split("\/").last
  #         else
  #           puts response.body, response.status
  #           nil
  #         end
  #       end
  #     when Relationship
  #       from_id = @node_ids[item.from_id]
  #       to_id = @node_ids[item.to_id]
  #       name = item.relation.name

  #       data = {
  #         "id" => item.id,
  #         "to" => node_url(to_id),
  #         "type" => name,
  #         "data" => {
  #           "uuid" => item.uuid,
  #           "created_at" => item.created_at.to_f,
  #           "updated_at" => item.updated_at.to_f
  #         }
  #       }

  #       if bulk
  #         {"to" => "/node/#{from_id}/relationships", "method" => "post", "body" => data}
  #       else
  #         response = request "post", "#{node_path(from_id)}/relationships", {}, data.to_json
  #         if response.ok?
  #           # puts "success"
  #         else
  #           puts response.body, response.status
  #           nil          
  #         end 
  #       end
  #     when Relation
  #   end
  # end

  def update(item)
    case item
      when Entity
      when Relationship
      when Relation
    end
  end

  def cypher(statements = [])
    statements = [statements] unless statements.is_a?(Array)
    response = request "post", "/db/data/transaction/commit", {}, Oj.dump(
      "statements" => statements
    )

    # binding.pry

    if response.ok?
      JSON.parse(response.body)
    else
      puts response.body, response.status
      nil
    end    
  end

  def simple_cypher(statement)
    cypher("statement" => statement)
  end

  def commit(statement)
    response = request "post", "/db/data/transaction/commit", {}, {
      "statements" => [{"statement" => statement}]
    }.to_json

    if response.ok?
      JSON.parse(response.body)
    else
      puts response.body, response.status
      nil
    end
  end

  def find_id_by_uuid(uuid)
    if data = commit("MATCH n WHERE n.uuid = '#{uuid}' RETURN id(n)")
      if d = data["results"].first["data"].first
        d["row"].first
      end
    end
  end

  def node_url(id)
    "#{@options[:base_url]}#{node_path id}"
  end

  def node_path(id)
    "/db/data/node/#{id}"
  end

  def find(item)
    case item
      when Entity
        response = request "post", "/db/data/transaction/commit", {}, {
          "statements" => [
            {"statement" => "MATCH n WHERE n.uuid = '#{item.uuid}' RETURN n, id(n)"}
          ]
        }.to_json

        if response.ok?
          data = JSON.parse(response.body)
          data["results"].first["data"].first["row"].first
        end
      when Relationship
      when Relation
    end
  end

  def search

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

      client.request(method, "#{@options[:base_url]}#{path}", params, body, headers)
    end

end