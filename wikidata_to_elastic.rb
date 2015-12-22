require "./config/environment"

class Kor::WikidataImporter
  def initialize(file)
    @file = file
  end

  def run
    progress = ProgressBar.create(
      :title => "Importing ...",
      :total => 19080000,
      :format => "%t |%B| %c done | %R/s | %a |%f"
    )

    drop_index

    reader, writer = IO.pipe
    Process.spawn "bunzip2 -c #{@file}", :out => writer

    buffer = []

    while line = reader.readline
      begin
        doc = Oj.load(line.gsub(/[,\s]*$/, ''))

        if doc["type"] == "item"
          begin
            elastic_data = {
              "_id" => doc["id"],
              "labels" => doc["labels"]
            }

            progress.increment
            buffer << Oj.dump("index" => {"_id" => doc['id']})
            buffer << Oj.dump(elastic_data)
          rescue NoMethodError => e
            p doc
            raise e
          end
        end

        if buffer.size > 1000
          bulk(buffer.join("\n"))
          buffer = []
        end
      rescue Oj::ParseError => e
        p e
      end
    end

    binding.pry
    x = 12
  end

  def client
    @client ||= HTTPClient.new
  end

  def bulk(data)
    request "POST", "/wikidata/items/_bulk", nil, data
  end

  def drop_index
    if index_exists?
      request "DELETE", "/wikidata"
      request "POST", "/_refresh"
    end
  end

  def post_item(data)
    request "POST", "/wikidata/items/#{data['_id']}", nil, Oj.dump(data)
  end

  def index_exists?
    begin
      response = request "GET", "/wikidata"
      true
    rescue => e
      false
    end
  end

  def request(method, path, params = nil, body = nil, headers = nil)
    response = client.request( 
      method,
      "http://localhost:9200#{path}",
      params,
      body,
      headers
    )

    if response.status < 200 || response.status >= 300
      puts response.status
      raise response.body
    end
  end

end

Kor::WikidataImporter.new("~/Desktop/cache/wikidata-20151207-all.json.bz2").run