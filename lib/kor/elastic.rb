class Kor::Elastic

  class Exception < ::Exception
    def initialize(message, data = {})
      @data = data
      super message
    end

    def message
      "#{super}: #{@data.inspect}"
    end
  end

  def self.enabled?
    !!config
  end

  def self.config
    @config ||= Rails.configuration.database_configuration[Rails.env]['elastic']
  end

  def self.enabled?
    !!config
  end

  def self.create_index
    request 'put', '/', nil, {
      "settings" => {
        "analysis" => {
          "analyzer" => {
            "folding" => {
              "tokenizer" => "standard",
              "filter" => ["lowercase", "asciifolding"]
            }
          }
        }
      }
    }

    request "put", "/entities/_mapping", nil, {
      "entities" => {
        "properties" => {
          "name" => {"type" => "string", "analyzer" => "folding"},
          "distinct_name" => {"type" => "string", "analyzer" => "folding"},
          "synonyms" => {"type" => "string", "analyzer" => "folding"},
          "comment" => {"type" => "string", "analyzer" => "folding"},
          "properties" => {
            "type" => "object", 
            "properties" => {
              "label" => {"type" => "string", "analyzer" => "folding"},
              "value" => {"type" => "string", "analyzer" => "folding"}
            }
          },
          "id" => {"type" => "string", "index" => "not_analyzed"},
          "uuid" => {"type" => "string", "index" => "not_analyzed"},
          "tags" => {"type" => "string", "analyzer" => "keyword"},

          "sort" => {"type" => "string", "index" => "not_analyzed"}
        }
      }
    }
  end

  def self.drop_index
    request 'delete', '/'
  end

  def self.index_exists?
    response = raw_request 'head', '/'
    response.status != 404
  end

  def self.reset_index
    drop_index if index_exists?
    create_index
  end

  def self.flush
    request "post", "/_flush"
  end

  def self.refresh
    request "post", "/_refresh"
  end

  def self.index_all(options = {})
    options.reverse_merge! :full => false, :progress => false

    @cache = {}

    total = Entity.without_media.count
    done = 0

    Entity.includes(:tags).without_media.find_each do |entity|
      index(entity, options)
      done += 1

      if options[:progress] && done % 100 == 0
        puts "indexed #{done}/#{total}"
      end

      # return if done == 1000
    end

    refresh
  end

  def self.index(entity, options = {})
    options.reverse_merge! :full => false    

    data = {
      "uuid" => entity.uuid,
      "name" => entity.name,
      "distinct_name" => entity.distinct_name,
      "tags" => entity.tags.map{|t| t.name},
      "synonyms" => fetch(:synonyms, entity.id){entity.synonyms},
      "kind_id" => entity.kind_id,
      "collection_id" => entity.collection_id,
      "comment" => entity.comment,
      "properties" => entity.properties,

      "sort" => entity.display_name
    }

    if options[:full]
      related_ids = Investigator.new.related_entities_for(entity.id).values.flatten.uniq
      scope = Entity.includes(:kind).where(:id => related_ids).select([:id, :attachment_id, :name, :kind_id])
      data["related"] = scope.map do |e|
        [e.name] + fetch(:synonyms, e.id) do
          e.synonyms
        end
      end
    end

    request 'put', "/entities/#{entity.uuid}", nil, data
  end

  def self.drop(entity)
    request 'delete', "/entities/#{entity.uuid}"
  end

  def self.empty_result
    ::Kor::SearchResult.new(:total => 0, :uuids => [])
  end

  def initialize(user)
    @user = user
  end

  def search(query = {})
    return empty_result unless self.class.enabled?

    page = [(query[:page] || 0).to_i, 1].max

    # data = {}
    query_component = nil

    if query[:query].present?
      q = wildcardize(escape tokenize(query[:query])).join(' ')
      query_component = {
        "query_string" => {
          "query" => q,
          "default_operator" => "AND",
          "analyzer" => "folding",
          "analyze_wildcard" => true,
          "fields" => [
            'uuid^20',
            'name^10',
            'distinct_name^5',
            'synonyms^5',
            'properties.label^2',
            'properties.value^3',
            '_all'
          ]
        }
      }
    end

    collection_ids = ::Auth::Authorization.authorized_collections(@user).map(&:id)
    if collection_ids.empty?
      return self.class.empty_result
    end

    if query[:collection_id].present?
      collection_ids &= to_array(query[:collection_id])
    end

    filters = [
      {
        "terms" => {
          "collection_id" => collection_ids,
        }
      }
    ]

    if query[:tags].present?
      filters << {
        "terms" => {
          "tags" => to_array(query[:tags]),
          "execution" => "and"
        }
      }
    end

    if query[:kind_id].present?
      filters << {
        "terms" => {
          "kind_id" => to_array(query[:kind_id])
        }
      }
    end

    data = {
      "size" => 10,
      "from" => (page - 1) * 10,
      "query" => {
        "filtered" => {
          "filter" => {
            "bool" => {
              "must" => filters
            }
          }
        }
      }
    }

    if query[:query].blank? && query[:tags].blank?
      data["sort"] = {"sort" => "asc"}
    end

    if query_component
      data["query"]["filtered"]["query"] = query_component
    end

    # puts JSON.pretty_generate(data)

    response = self.class.request "post", "/entities/_search", nil, data

    if response.first == 200
      # puts JSON.pretty_generate(response)
      ::Kor::SearchResult.new(
        :total => response.last['hits']['total'],
        :uuids => response.last['hits']['hits'].map{|hit| hit['_id']},
        :page => page
      )
    else
      p response
      response
    end
  end

  def count
    response = self.class.request('get', '/entities/_count')
    
    if response.first == 404
      self.class.create_index
    else
      response.last['count']
    end
  end


  protected

    def self.client
      @client ||= HTTPClient.new
    end

    def self.request(method, path, query = {}, body = nil, headers = {})
      return :disabled if !enabled?

      response = raw_request(method, path, query, body, headers)

      if response.status >= 200 && response.status <= 299
        [response.status, response.headers, Oj.load(response.body, :mode => :strict)]
      else
        raise Exception.new("error", [response.status, response.headers, Oj.load(response.body, :mode => :strict)])
      end
    end

    def self.raw_request(method, path, query = {}, body = nil, headers = {})
      return :disabled if !enabled?

      Rails.logger.info "ELASTIC: #{method} #{path}\n#{body.inspect}"

      headers.reverse_merge 'content-type' => 'application/json', 'accept' => 'application/json'
      url = "http://#{config['host']}:#{config['port']}/#{config['index']}#{path}"
      client.request(method, url, query, (body ? JSON.dump(body) : nil), headers)      
    end

    def tokenize(query_string)
      query_string = "" if query_string.blank?
      query_string = query_string.join(' ') if query_string.is_a?(Array)

      query_string.scan(/\"[^\"]*\"|[^\"\s]+/).select do |term|
        term.size >= 3
      end
    end

    def escape(terms)
      terms.map do |term|
        term.gsub /[\-]/ do |m|
          '\\' + m
        end
        # + - && || ! ( ) { } [ ] ^ ~ * ? : \ /
      end
    end

    def wildcardize(tokens)
      tokens.map do |term|
        "*#{term}*"
      end
    end

    def to_array(value)
      value.is_a?(Array) ? value : [value]
    end

    def self.fetch(*args)
      if @cache.is_a?(Hash)
        key = args.map(&:to_s).join('.')
        @cache[key] ||= yield
      else
        yield
      end
    end

end