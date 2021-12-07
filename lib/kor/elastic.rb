class Kor::Elastic
  class Exception < RuntimeError
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
      'index' => ENV['ELASTIC_INDEX'],
      'token' => ENV['ELASTIC_TOKEN']
    }
  end

  def self.available?
    return false if @disabled

    ENV['ELASTIC_URL'].present?
  end

  def self.disable!
    @disabled = true
  end

  def self.enable!
    @disabled = false
  end

  # def self.enabled=(value)
  #   @enabled = value
  # end

  # def self.enabled?
  #   available? && (@enabled != false)
  # end

  def self.current_index
    config['index']
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
                  "tokenizer" => 'standard',
                  "filter" => ['lowercase', 'my_ascii_folding']
                },
                # "default" => {
                #   'type' => 'custom',
                #   "tokenizer" => 'gram',
                #   "filter" => ['asciifolding', 'lowercase']
                # },
                # 'default_search' => {
                #   'type' => 'standard',
                #   'tokenizer' => 'gram',
                #   "filter" => ['asciifolding', 'lowercase']
                # }
              },
              'filter' => {
                'my_ascii_folding' => {
                  'type' => 'asciifolding',
                  'preserve_original' => true
                }
              }
              # 'tokenizer' => {
              #   'gram' => {
              #     'type' => 'ngram',
              #     'min_gram' => 2,
              #     'max_gram' => 30
              #   }
              # }
            },
            "max_result_window": [Entity.count * 2, 10000].max
          }
        },
        'mappings' => {
          "entities" => {
            "properties" => {
              "name" => {"type" => "text"},
              "distinct_name" => {"type" => "text"},
              "subtype" => {"type" => "text"},
              "synonyms" => {"type" => "text"},
              "comment" => {"type" => "text"},
              'datings' => {
                'type' => 'object',
                'properties' => {
                  'label' => {'type' => 'text'},
                  'from' => {'type' => 'integer'},
                  'to' => {'type' => 'integer'}
                }
              },
              "dataset" => {
                "type" => "object",
                "properties" => {
                  "_default_" => {"type" => "text"}
                }
              },
              "properties" => {
                "type" => "object",
                "properties" => {
                  "label" => {"type" => "text"},
                  "value" => {"type" => "text"}
                }
              },
              "id" => {"type" => "keyword"},
              "uuid" => {"type" => "text"},
              "tags" => {"type" => "text", "analyzer" => "keyword"},
              "related" => {
                "type" => "nested",
                "properties" => {
                  "relation_name" => {"type" => "text"},
                  "entity_name" => {"type" => "text"},
                  "entity_collection_id" => {'type' => 'integer'}
                }
              },
              'degree' => {'type' => 'float'},
              'created_at' => {'type' => 'integer'},
              'updated_at' => {'type' => 'integer'},
              'creator_id' => {'type' => 'integer'},
              'updater_id' => {'type' => 'integer'},

              'file_size' => {'type' => 'integer'},
              'file_type' => {'type' => 'keyword'},
              'file_name' => {'type' => 'keyword'},
              'datahash' => {'type' => 'keyword'},

              "sort" => {"type" => "keyword", "index" => false},
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

  def self.ensure_index
    create_index unless index_exists?
  end

  def self.flush
    request "post", "/_flush"
  end

  def self.refresh
    request "post", "/_refresh"
  end

  def self.index_all(options = {})
    # TODO: shouldn't :full be true by default?
    options.reverse_merge! full: false, progress: false

    @cache = {}

    progress = if options[:progress]
      Kor.progress_bar('indexing entities', Entity.count)
    end
    scope = if options[:full]
      Entity.includes(:datings, :tags, outgoing_relationships: :to)
    else
      Entity.includes(:datings, :tags)
    end
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
      "tags" => entity.tags.map{ |t| t.name },
      "synonyms" => fetch(:synonyms, entity.id){ entity.synonyms },
      "kind_id" => entity.kind_id,
      "collection_id" => entity.collection_id,
      "comment" => entity.comment,
      "properties" => entity.properties,
      "dataset" => entity.dataset,
      'created_at' => entity.created_at.to_i,
      'updated_at' => entity.updated_at.to_i,
      'updater_id' => entity.updater_id,
      'creator_id' => entity.creator_id,
      'datings' => entity.datings.map{ |d|
        {'label' => d.dating_string, 'from' => d.from_day, 'to' => d.to_day}
      },
      'degree' => entity.degree,
      "sort" => entity.display_name
    }

    if entity.medium
      data.merge!(
        'file_size' => entity.medium.file_size,
        'file_type' => entity.medium.content_type,
        'file_name' => entity.medium.original_filename,
        'datahash' => entity.medium.datahash
      )
    end

    if options[:full]
      scope = entity.
        outgoing_relationships
      # select([:id, :name, :kind_id, :attachment])

      data["related"] = scope.map do |dr|
        next nil unless dr.to

        names = [dr.to.name] + fetch(:synonyms, dr.to_id) do
          dr.to.synonyms
        end
        {
          'relation_name' => dr.relation_name,
          'entity_name' => names,
          'entity_collection_id' => dr.to.collection_id
        }
      end.flatten.select{ |e| e.present? }
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
    self.class.ensure_index

    @user = user
    @query = {
      'must' => [],
      'filter' => [],
      'must_not' => []
    }
  end

  def search(criteria = {})
    raise Kor::Exception unless self.class.available?

    criteria.reverse_merge!(
      analyzer: 'folding',
      page: 1,
      per_page: 10,
      sort: {column: '_score', direction: 'desc'}
    )

    criteria[:terms] = by_name(criteria[:terms], criteria[:name])
    criteria[:terms] = by_property(criteria[:terms], criteria[:property])

    by_user(@user)
    by_id(criteria[:id])
    by_uuid(criteria[:uuid])
    by_kind(criteria[:kind_id])
    by_kind_except(criteria[:except_kind_id])
    by_collection(criteria[:collection_id])
    by_terms(criteria[:terms])
    by_relation_name(criteria[:relation_name])
    by_created_after(criteria[:created_after])
    by_created_before(criteria[:created_before])
    by_updated_after(criteria[:updated_after])
    by_updated_before(criteria[:updated_before])
    by_dating(criteria[:dating])
    by_tag(criteria[:tags])
    by_dataset(criteria[:dataset])
    by_related(criteria[:related])
    by_degree(criteria[:degree])
    by_max_degree(criteria[:max_degree])
    by_min_degree(criteria[:min_degree])
    by_created_by(criteria[:created_by])
    by_updated_by(criteria[:updated_by])
    by_file_size(criteria[:file_size])
    by_file_size(criteria[:larger_than], :larger)
    by_file_size(criteria[:smaller_than], :smaller)
    by_file_type(criteria[:file_type])
    by_file_name(criteria[:file_name])
    by_datahash(criteria[:datahash])

    data = {
      'query' => {'bool' => @query},
      'size' => criteria[:per_page],
      'from' => (criteria[:page] - 1) * criteria[:per_page],
      'sort' => sorting(criteria[:sort]),
      'explain' => !Rails.env.production?
    }
    data['function_score'] = @function_score if @function_score
    data['query']['nested'] = @nested if @nested

    # puts JSON.pretty_generate(data)

    response = self.class.request "post", "/entities/_search", nil, data
    # puts JSON.pretty_generate(response)
    # binding.pry

    ::Kor::SearchResult.new(
      total: response['hits']['total'],
      uuids: response['hits']['hits'].map{ |hit| hit['_id'] },
      ids: response['hits']['hits'].map{ |hit| hit['_source']['id'] },
      raw_records: response['hits']['hits'],
      page: criteria[:page],
      per_page: criteria[:per_page]
    )
  end

  def sorting(sort)
    case sort[:column]
    when 'name' then [{'sort' => sort[:direction]}]
    when 'default' then [{'sort' => 'asc'}]
    when 'score' then ['_score']
    when 'random'
      @query['must'] << {
        'function_score' => {
          'random_score' => {'seed' => Time.now.to_i}
        }
      }

      ['_score']
    else
      [{sort[:column] => sort[:direction]}]
    end
  end

  def by_user(user)
    ids = ::Kor::Auth.authorized_collections(user).pluck(:id)
    if ids.empty?
      none
    else
      by_collection(ids)
    end
  end

  def by_id(ids)
    if ids.present?
      @query['filter'] << {
        'terms' => {'id' => to_array(ids)}
      }
    end
  end

  def by_uuid(ids)
    if ids.present?
      @query['filter'] << {
        'terms' => {'_id' => to_array(ids)}
      }
    end
  end

  def by_collection(ids)
    if ids.present?
      @query['filter'] << {
        'terms' => {'collection_id' => to_array(ids)}
      }
    end
  end

  def by_kind(ids)
    if ids.present?
      @query['filter'] << {
        'terms' => {'kind_id' => to_array(ids)}
      }
    end
  end

  def by_kind_except(ids)
    if ids.present?
      @query['must_not'] << {
        'terms' => {'kind_id' => to_array(ids)}
      }
    end
  end

  def by_created_after(time)
    if time.present?
      @query['filter'] << {
        'range' => {'created_at' => {'gt' => time.to_i}}
      }
    end
  end

  def by_created_before(time)
    if time.present?
      @query['filter'] << {
        'range' => {'created_at' => {'lt' => time.to_i}}
      }
    end
  end

  def by_updated_after(time)
    if time.present?
      @query['filter'] << {
        'range' => {'updated_at' => {'gt' => time.to_i}}
      }
    end
  end

  def by_updated_before(time)
    if time.present?
      @query['filter'] << {
        'range' => {'updated_at' => {'lt' => time.to_i}}
      }
    end
  end

  def by_dating(dating)
    if dating.present?
      to_array(dating).each do |d|
        if parsed = Dating.parse(d)
          from = EntityDating.julian_date_for(parsed[:from])
          to = EntityDating.julian_date_for(parsed[:to])
          @query['filter'] << {
            'range' => {'datings.to' => {'gt' => from}}
          }
          @query['filter'] << {
            'range' => {'datings.from' => {'lt' => to}}
          }
        end
      end
    end
  end

  def by_tag(tags)
    if tags.present?
      to_array(tags).each do |tag|
        @query['filter'] << {
          'term' => {'tags' => tag}
        }
      end
    end
  end

  def by_dataset(dataset)
    if dataset.present?
      dataset.each do |field, value|
        @query['must'] << {
          'match' => {"dataset.#{field}" => value}
        }
      end
    end
  end

  def by_related(related)
    if related.present?
      ids = ::Kor::Auth.authorized_collections(@user).pluck(:id)
      @query['must'] << {
        'nested' => {
          'path' => 'related',
          'score_mode' => 'avg',
          'query' => {
            'bool' => {
              'must' => [
                {'match' => {'related.entity_name' => related}},
              ],
              'filter' => [
                {'terms' => {'related.entity_collection_id' => ids}}
              ]
            }
          }
        }
      }
    end
  end

  def by_degree(degree)
    if degree.present?
      @query['filter'] << {
        'term' => {'degree' => degree}
      }
    end
  end

  def by_min_degree(degree)
    if degree.present?
      @query['filter'] << {
        'range' => {'degree' => {'gte' => degree}}
      }
    end
  end

  def by_max_degree(degree)
    if degree.present?
      @query['filter'] << {
        'range' => {'degree' => {'lte' => degree}}
      }
    end
  end

  def by_name(old_terms, name)
    name.present? ? (old_terms || '') + " name:(#{name}) OR distinct_name:(#{name})" : old_terms
  end

  def by_property(old_terms, property)
    if property.present?
      (old_terms || '') +
        " properties.label:(#{property}) OR properties.value:(#{property})"
    else
      old_terms
    end
  end

  def by_terms(terms)
    if terms.present?
      @query['must'] << {
        "query_string" => {
          "query" => terms,
          "default_operator" => "AND",
          # "analyzer" => query[:analyzer],
          "analyze_wildcard" => true,
          'allow_leading_wildcard' => true,
          # 'lowercase_expanded_terms' => false,
          # 'auto_generate_phrase_queries' => true,
          'lenient' => true,
          'use_dis_max' => true,
          'fuzziness' => 0,
          "fields" => [
            'uuid^20',
            'name^10',
            'subtype^8',
            'distinct_name^2',
            'synonyms^6',
            'dataset.*^5',
            'related.relation_name^1',
            'related.entity_name^1',
            'properties.value^3',
            'properties.label^2',
            'comment^1',
            '_all'
          ]
        }
      }
    end
  end

  def by_relation_name(relation_name)
    if relation_name.present?
      ids = Relation.to_entity_kind_ids(relation_name)
      @query['filter'] << {
        'terms' => {'kind_id' => ids}
      }
    end
  end

  def by_created_by(id)
    if id.present?
      @query['filter'] << {
        'term' => {'creator_id' => id}
      }
    end
  end

  def by_updated_by(id)
    if id.present?
      @query['filter'] << {
        'term' => {'updater_id' => id}
      }
    end
  end

  def by_file_size(size, mode = :equal)
    return if size.blank?

    case mode
    when :equal
      @query['filter'] << {
        'term' => {'file_size' => size}
      }
    when :smaller
      @query['filter'] << {
        'range' => {'file_size' => {'lte' => size}}
      }
    when :larger
      @query['filter'] << {
        'range' => {'file_size' => {'gte' => size}}
      }
    end
  end

  def by_file_type(type)
    if type.present?
      @query['filter'] << {
        'term' => {'file_type' => type}
      }
    end
  end

  def by_file_name(name)
    if name.present?
      @query['filter'] << {
        'term' => {'file_name' => name}
      }
    end
  end

  def by_datahash(hash)
    if hash.present?
      @query['filter'] << {
        'term' => {'datahash' => hash}
      }
    end
  end

  def none
    @query['filter'] << {
      'terms' => {'collection_id' => []}
    }
  end

  def self.count
    response = request('get', '/entities/_count')
    response['count']
  end

  def self.client
    @client ||= HTTPClient.new
  end

  def self.request(method, path, query = {}, body = nil, headers = {})
    raise Kor::Exception, "elasticsearch is not available" if !available?
    # raise Kor::Exception, "elasticsearch functionality has been disabled" if !enabled?

    query ||= {}
    path = "/#{current_index}#{path}"
    body = (body ? JSON.dump(body) : nil)
    response = raw_request(method, path, query, body, headers)
    require_ok(response)

    # Rails.logger.debug "ELASTIC RESPONSE: #{response.inspect}"
    JSON.load(response.body)
  end

  def self.raw_request(method, path, query = {}, body = nil, headers = {})
    Rails.logger.info "ELASTIC REQUEST: #{method} #{path}\n#{body.inspect}"

    query['token'] = config['token'] if config['token']
    headers.reverse_merge! 'content-type' => 'application/json', 'accept' => 'application/json'
    url = "#{config['url']}#{path}"
    client.request(method, url, query, body, headers)
  end

  def self.require_ok(response)
    if response.status < 200 || response.status >= 300
      raise StandardError, [
        "elastic request failed: #{response.status}: ",
        'HEADERS: ', response.headers.inspect, ' ',
        'BODY: ', response.body
      ].join
    end
  end

  def self.fetch(*args)
    if @cache.is_a?(Hash)
      key = args.map(&:to_s).join('.')
      @cache[key] ||= yield
    else
      yield
    end
  end

  protected

    def to_array(value)
      return [] if value.nil?

      value.is_a?(Array) ? value : [value]
    end
end
