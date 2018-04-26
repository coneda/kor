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

  def self.config
    @config ||= {
      'url' => ENV['ELASTIC_URL'],
      'index_a' => ENV['ELASTIC_INDEX_A'],
      'index_b' => ENV['ELASTIC_INDEX_B'],
      'token' => ENV['ELASTIC_TOKEN']
    }
  end

  def self.current_index
    # TODO: make this switch to the alternate index by some mechanism
    config['index_a']
  end

  def self.enabled?
    case @enabled
      when true then true
      when false then false
      else
        config['ELASTIC_URL'] && !Rails.env.test?
    end
  end

  def self.enable
    @enabled = true
  end

  def self.disable
    @enabled = false
  end

  def self.server_version
    response = raw_request('get', '/')
    require_ok(response)
    version = JSON.parse(response.body)['version']['number']
    Semantic::Version.new(version)
  end

  def self.create_index
    unless index_exists?
      request 'put', '/', nil, {
        "settings" => {
          'index' => {
            "analysis" => {
              "analyzer" => {
                "default" => {
                  'type' => 'custom',
                  "tokenizer" => 'gram',
                  "filter" => ['asciifolding', 'lowercase']
                },
                'default_search' => {
                  'type' => 'custom',
                  'tokenizer' => 'gram',
                  'filter' => ['asciifolding', 'lowercase']
                }
              },
              'tokenizer' => {
                'gram' => {
                  'type' => 'ngram',
                  'min_gram' => 2,
                  'max_gram' => 30
                }
              }
              # 'tokenizer' => {
              #   'gram' => {
              #     'type' => 'ngram',
              #     'min_gram' => 3,
              #     'max_gram' => 30
              #     # 'token_chars' => ['letter']
              #   }
              # }
            }
          }
        },
        'mappings' => {
          "entities" => {
            "properties" => {
              "name" => {
                "type" => "string"
                # 'index_options' => 'docs',
                # 'norms' => {'enabled' => false}
              },
              "distinct_name" => {
                "type" => "string"
                # 'index_options' => 'docs',
                # 'norms' => {'enabled' => false}
              },
              "subtype" => {"type" => "string"},
              "synonyms" => {"type" => "string"},
              "comment" => {"type" => "string"},
              "dataset" => {
                "type" => "object",
                "properties" => {
                  "_default_" => {"type" => "string"}
                }
              },
              "properties" => {
                "type" => "object", 
                "properties" => {
                  "label" => {"type" => "string"},
                  "value" => {"type" => "string"}
                }
              },
              "id" => {"type" => "string", "index" => "not_analyzed"},
              "uuid" => {"type" => "string"},
              "tags" => {"type" => "string", "analyzer" => "keyword"},
              "related" => {"type" => "string"},
              'degree' => {'type' => 'float'},

              "sort" => {"type" => "string", "index" => "not_analyzed"},
            }
          }
        }
      }
    end
  end

  def self.drop_index
    if index_exists?
      request 'delete', '/'
    end
  end

  def self.index_exists?
    response = raw_request 'head', "/#{current_index}"
    response.status != 404
  end

  def self.reset_index
    drop_index
    create_index
  end

  def self.flush
    request "post", "/_flush"
  end

  def self.refresh
    request "post", "/_refresh"
  end

  def self.index_all(options = {})
    return unless enabled?

    options.reverse_merge! :full => false, :progress => false

    @cache = {}

    progress = if options[:progress]
      Kor.progress_bar('indexing entities', Entity.without_media.count)
    end
    scope = Entity.includes(:tags).without_media
    scope.find_in_batches do |batch|
      data = []
      batch.map do |e|
        data << JSON.dump('index' => {'_id' => e.uuid})
        data << JSON.dump(data_for(e, options))
        progress.increment if options[:progress]
      end.join("\n")
      bulk(data.join "\n")
    end

    refresh
  end

  def self.get(entity)
    request 'get', "/entities/#{entity.uuid}"
  end

  def self.data_for(entity, options = {})
    options.reverse_merge! :full => false

    data = {
      "id" => entity.id,
      "uuid" => entity.uuid,
      "name" => entity.name,
      "distinct_name" => entity.distinct_name,
      "subtype" => entity.subtype,
      "tags" => entity.tags.map{|t| t.name},
      "synonyms" => fetch(:synonyms, entity.id){entity.synonyms},
      "kind_id" => entity.kind_id,
      "collection_id" => entity.collection_id,
      "comment" => entity.comment,
      "properties" => entity.properties,
      "dataset" => entity.dataset,

      'degree' => entity.degree,
      "sort" => entity.display_name
    }

    if options[:full]
      scope = entity.
        outgoing.
        without_media.
        select([:id, :name, :kind_id, :attachment])

      data["related"] = scope.map do |e|
        [e.name] + fetch(:synonyms, e.id) do
          e.synonyms
        end
      end.flatten.select{|e| e.present?}
    end

    data
  end

  def self.index(entity, options = {})
    data = data_for(entity, options)
    request 'put', "/entities/#{entity.uuid}", nil, data
  end

  def self.drop(entity)
    request 'delete', "/entities/#{entity.uuid}"
  end

  def self.empty_result
    ::Kor::SearchResult.new(:total => 0, :uuids => [])
  end

  def self.bulk(data)
    data << "\n" unless data.match(/\n$/)
    response = raw_request 'post', "/#{current_index}/entities/_bulk", nil, data
    require_ok(response)
  end

  def initialize(user)
    @user = user
  end

  def search(query = {})
    query[:analyzer] ||= 'folding'

    return self.class.empty_result unless self.class.enabled?

    # puts JSON.pretty_generate(query)

    page = [(query[:page] || 0).to_i, 1].max
    per_page = [(query[:per_page] || 10).to_i, 500].min

    # data = {}
    query_component = nil

    q = []

    if query[:query].present?
      q += if query[:raw]
        [query[:query]]
      else
        result = if Kor.is_uuid?(query[:query])
          [query[:query]]
        else
          escape tokenize(query[:query])
        end
        result.empty? ? [] : [result.join(' ')]
      end
    end

    if query[:properties]
      v = query[:properties]
      q << "properties.label:\"#{v}\" OR properties.value:\"#{v}\""
    end

    if query[:dataset].present?
      query[:analyzer] = nil
      query[:dataset].each do |k, v|
        if v.present?
          q << "dataset.#{k}:\"#{v}\""
        end
      end
    end

    if query[:synonyms].present?
      v = escape(tokenize(query[:synonyms])).join(' ')
      q << "synonyms:(#{v})" unless v.blank?
    end

    if q.present?
      q = "(#{q.join ') AND ('})"

      query_component = {
        "query_string" => {
          "query" => q,
          "default_operator" => "AND",
          # "analyzer" => query[:analyzer],
          "analyze_wildcard" => true,
          'allow_leading_wildcard' => true,
          # 'lowercase_expanded_terms' => false,
          # 'auto_generate_phrase_queries' => true,
          'use_dis_max' => true,
          "fields" => [
            'uuid^20',
            'name^10',
            'subtype^8',
            'distinct_name^2',
            'synonyms^6',
            'dataset.*^5',
            'related^1',
            'properties.value^3',
            'properties.label^2',
            'comment^1',
            '_all'
          ]
        }
      }
    end

    collection_ids = ::Kor::Auth.authorized_collections(@user).map(&:id)
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
      Kor.array_wrap(query[:tags]).each do |tag|
        filters << {
          "term" => {
            "tags" => tag
          }
        }
      end
    end

    if query[:kind_id].present?
      filters << {
        "terms" => {
          "kind_id" => to_array(query[:kind_id])
        }
      }
    end

    sorting = [{'sort' => 'asc'}]
    if query[:query].present? || query[:tags].present?
      sorting.unshift 'degree' => 'desc'
      sorting.unshift '_score'
    end

    data = build_request(
      page: page,
      per_page: per_page,
      queries: (query_component ? [query_component] : []),
      filters: filters,
      sorting: sorting
    )

    # puts JSON.pretty_generate(data)

    data['explain'] = true unless Rails.env.production?
    response = self.class.request "post", "/entities/_search", nil, data

    # puts JSON.pretty_generate(response)
    # binding.pry

    ::Kor::SearchResult.new(
      :total => response['hits']['total'],
      :uuids => response['hits']['hits'].map{|hit| hit['_id']},
      :ids => response['hits']['hits'].map{|hit| hit['_source']['id']},
      :raw_records => response['hits']['hits'],
      :page => page
    )
  end

  def build_request(options = {})
    if self.class.server_version < '5.0.0'
      data = {
        'size' => options[:per_page],
        'from' => (options[:page] - 1) * options[:per_page],
        'query' => {
          'filtered' => {
            'filter' => {
              'bool' => {
                'must' => options[:filters]
              }
            }
          }
        }
      }

      unless options[:queries].blank?
        data["query"]["filtered"]["query"] = options[:queries].first
      end

      unless options[:sorting].blank?
        data['sort'] = options[:sorting]
      end
      data
    else
      data = {
        'size' => options[:per_page],
        'from' => (options[:page] - 1) * options[:per_page],
        'sort' => options[:sorting],
        'query' => {
          'bool' => {
            'filter' => options[:filters],
            'must' => options[:queries]
            # 'should' => [
            #   # {
            #   #   'function_score' => {
            #   #     'query' => {'match_all' => {}},
            #   #     'functions' => [
            #   #       # {
            #   #       #   'script_score' => {
            #   #       #     'script' => "doc['name'] ? doc['name'].length : 0.0"
            #   #       #   }
            #   #       # }
            #   #       # {
            #   #       #   'field_value_factor' => {
            #   #       #     'field' => 'degree',
            #   #       #     'factor' => 0.01
            #   #       #   }
            #   #       # }
            #   #     ]
            #   #   }
            #   # }
            # ]
          }
        }
      }
    end
  end

  def count
    return 0 unless self.class.enabled?

    response = self.class.request('get', '/entities/_count')
    response['count']
  end


  protected

    def self.client
      @client ||= HTTPClient.new
    end

    def self.request(method, path, query = {}, body = nil, headers = {})
      return :disabled if !enabled?
      query ||= {}
      path = "/#{current_index}#{path}"
      body = (body ? JSON.dump(body) : nil)
      url = "http://#{config['url']}#{path}"
      response = raw_request(method, path, query, body, headers)
      require_ok(response)

      # Rails.logger.debug "ELASTIC RESPONSE: #{response.inspect}"
      JSON.load(response.body)
    end

    def self.raw_request(method, path, query = {}, body = nil, headers = {})
      return :disabled if !enabled?

      Rails.logger.info "ELASTIC REQUEST: #{method} #{path}\n#{body.inspect}"

      query['token'] = config['token'] if config['token']
      headers.reverse_merge 'content-type' => 'application/json', 'accept' => 'application/json'
      url = "http://#{config['url']}#{path}"
      client.request(method, url, query, body, headers)
    end

    def self.require_ok(response)
      if response.status < 200 || response.status >= 300
        raise Exception.new("error", [response.status, response.headers, JSON.load(response.body)])
      end
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