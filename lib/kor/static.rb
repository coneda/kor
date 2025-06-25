class Kor::Static
  def initialize(opts = {})
    @opts = opts.reverse_merge(
      per_page: Kor.settings['max_results_per_request'],
      page_limit: 3,
      user: User.admin,
      pretty: true,
      media_override: nil
    )

    @originals_collection_ids = Kor::Auth.
      authorized_collections(@opts[:user], :download_originals).
      pluck(:id)
  end

  def activate
    deactivate

    system 'mkdir', '-p', target

    session
    kinds
    relations
    entities
  end

  def deactivate
    system 'rm', '-rf', target
  end


  protected

    def kinds
      with_all 'kinds', include: 'all'
    end

    def relations
      with_all 'relations', include: 'all'
    end

    def entities
      irpr = Kor.settings['max_included_results_per_result']
      Kor.settings['max_included_results_per_result'] = Entity.count

      index = {}

      params = {
        engine: 'active_record',
        include: 'technical,synonyms,datings,dataset,properties,gallery_data,related,groups,degree',
        sort: 'created_at',
        direction: 'desc'
      }
      with_all 'entities', params do |entity|
        p entity if entity['gallery_data']
        media_for(entity)

        index[entity['id']] = {
          id: entity['id'],
          display_name: entity['display_name']
        }
      end

      File.write "#{target}/entities.json", to_json(index)

      Kor.settings['max_included_results_per_result'] = irpr
    end

    def with_all(type, params, &block)
      system 'mkdir', '-p', "#{target}/#{type}"

      data = request("#{type}", {per_page: 1, engine: 'active_record'})
      pages = (data['total'] / data['per_page']).ceil
      pages = [pages, @opts[:page_limit]].min if @opts[:page_limit]
      pg = Kor.progress_bar type, data['total']

      (1..pages).each do |page|
        rp = params.merge(
          per_page: @opts[:per_page],
          page: page
        )
        results = request(type, rp)
        results['records'].each do |record|
          yield record if block_given?

          File.write "#{target}/#{type}/#{record['id']}.json", to_json(record)
          pg.increment
        end
      end
    end

    def media_for(entity)
      return unless entity['medium']

      cid = entity['collection_id']

      symlinks = ['icon', 'thumbnail', 'preview', 'screen', 'normal']
      symlinks << 'original' if @originals_collection_ids.include?(cid)

      symlinks.each do |s|
        url = entity['medium']['url'][s]
        path = url.split('?')[0]
        source = @opts[:media_override] || "#{ENV['DATA_DIR']}#{path}"
        dest = "#{target}#{path}"
        dir = File.dirname(dest)

        system 'mkdir', '-p', dir
        system 'ln', '-sfn', source, dest

        entity['medium']['url'][s] = "/static#{path}"
      end
    end

    def session
      data = request('/session')

      data['session'].delete 'csrfToken'
      data['session'].delete 'user'

      data['perPage'] = @opts[:per_page]

      File.write "#{target}/session.json", to_json(data)
    end

    def target
      "#{Rails.root}/public/static"
    end

    def request(path, params = nil)
      @http ||= Faraday.new(
        ENV['ROOT_URL'],
        request: {timeout: 30},
        headers: {
          'accept' => 'application/json',
          'api-key' => @opts[:user].api_key
        }
      )

      response = @http.get(path, params)
      binding.pry unless response.success?

      JSON.parse(response.body)
    end

    def to_json(data)
      (@opts[:pretty] ? JSON.pretty_generate(data) : JSON.dump(data))
    end
end
