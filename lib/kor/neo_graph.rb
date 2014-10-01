class Kor::NeoGraph

  def initialize(user, options = {})
    @user = user
    @options = options.reverse_merge(
      :base_dir => "/opt/neo4j-community-2.1.4",
      :base_url => "http://localhost:7474"
    )
  end

  def reset!
    system "#{@options[:base_dir]}/bin/neo4j stop"
    system "rm -rf #{@options[:base_dir]}/data/*"
    system "#{@options[:base_dir]}/bin/neo4j start"
  end

  def store(item)
    case item
      when Entity

      when Relationship
      when Relation
    end
  end

  def create(item)
    case item
      when Entity
        data = {
          "uuid" => item.uuid,
          "name" => item.display_name,
          "kind_id" => item.kind_id
        }

        response = request "post", "/db/data/node", {}, data.to_json
        if response.ok?
          response.headers["Location"].split("\/").last
        end
      when Relationship
        from_id = find_id_by_uuid(item.from.uuid) || create(item.from)
        to_id = find_id_by_uuid(item.to.uuid) || create(item.to)
        name = item.relation.name

        data = {
          "to" => node_url(to_id),
          "type" => name,
          "data" => {
            "uuid" => item.uuid
          }
        }

        response = request "post", "#{node_path(from_id)}/relationships", {}, data.to_json

        unless response.ok?
          puts response.body
          nil          
        end 
      when Relation
    end
  end

  def update(item)
    case item
      when Entity
      when Relationship
      when Relation
    end
  end

  def commit(statement)
    response = request "post", "/db/data/transaction/commit", {}, {
      "statements" => [{"statement" => statement}]
    }.to_json

    if response.ok?
      JSON.parse(response.body)
    else
      puts response.body
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
    "#{@options[:base_url]}/#{node_path id}"
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