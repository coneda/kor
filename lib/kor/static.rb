class Kor::Static
  def initialize(opts = {})
    @opts = opts.reverse_merge(
      per_page: Kor.settings['max_results_per_request'],
      page_limit: 3,
      user: User.admin,
      pretty: true,
      media_override: nil,
      media_override: '/content_types/image.gif'
    )

    @originals_collection_ids = Kor::Auth.
      authorized_collections(@opts[:user], :download_originals).
      pluck(:id)

    @entity_ids = []
    @groups = {}
  end

  def activate
    # deactivate

    system 'mkdir', '-p', target

    info
    # session
    # settings
    # statistics
    # translations
    # kinds
    # relations
    # collections
    # entities
    # relationships
    authority_groups
  end

  def deactivate
    recreate target
  end


  protected

    def recreate(dir)
      system 'rm', '-rf', dir
      system 'mkdir', '-p', dir
    end

    def authority_groups
      all = []
      with_all 'authority_groups', include: 'technical' do |record|
        record['entity_ids'] = @groups[record['id']] || []
        next if record['entity_ids'].empty?

        all << record
      end
      File.write "#{target}/authority_groups.json", to_json(to_result all)

      all = []
      with_all 'authority_group_categories', all: true, include: 'technical' do |record|
        all << record
      end
      File.write "#{target}/authority_group_categories.json", to_json(to_result all)
    end

    def kinds
      all = []

      with_all 'kinds', include: 'all' do |record|
        all << record
      end

      File.write "#{target}/kinds.json", to_json(to_result all)
    end

    def relations
      all = []

      with_all 'relations', include: 'all' do |record|
        all << record
      end

      File.write "#{target}/relations.json", to_json(to_result all)
    end

    def collections
      all = []

      with_all 'collections', include: 'all' do |record|
        all << record
      end

      File.write "#{target}/collections.json", to_json(to_result all)
    end

    def entities
      recreate "#{target}/entities"

      irpr = Kor.settings['max_included_results_per_result']
      Kor.settings['max_included_results_per_result'] = Entity.count

      all = []

      params = {
        engine: 'active_record',
        include: 'technical,synonyms,datings,dataset,properties,gallery_data,relations,groups,degree',
        sort: 'created_at',
        direction: 'desc'
      }
      with_all 'entities', params do |entity|
        all << {
          'id' => entity['id'],
          'name' => entity['display_name'],
          'uuid' => entity['uuid'],
          'kind_id' => entity['kind_id'],
          'tags' => entity['tags']
        }

        media_for(entity)

        File.write "#{target}/entities/#{entity['id']}.json", to_json(entity)

        entity['groups'].each do |ag|
          @groups[ag['id']] ||= []
          @groups[ag['id']] << entity['id']
        end
        @entity_ids << entity['id']
      end

      all = all.sort_by{|e| e['name']}
      File.write "#{target}/entities.json", to_json(all)

      Kor.settings['max_included_results_per_result'] = irpr
    end

    def relationships
      recreate "#{target}/relationships"

      by_from_id = {}

      @entity_ids.in_groups_of(10).each do |ids|
        id_list = ids.map{|id| id.to_s}.join(',')

        params = {
          include: 'all',
          from_entity_id: id_list
        }
        opts = {
          label: "relationships (#{id_list})",
          page_limit: false
        }
        with_all "relationships", params, opts do |r|
          apply_media_override(r['to'])

          from_id = r['from_id']
          by_from_id[from_id] ||= []
          by_from_id[from_id] << r
        end
      end

      by_from_id.each do |from_id, records|
        File.write "#{target}/relationships/#{from_id}.json", to_json(records)
      end

      @entity_ids.each do |id|
        file = "#{target}/relationships/#{id}.json"
        unless File.exist?(file)
          File.write file, to_json([])
        end
      end
    end

    def info
      data = request('/info.json')

      File.write "#{target}/info.json", to_json(data)
    end

    def session
      data = request('/session')

      delete_keys(data['session'], ['csrfToken'])
      permissions = data['session']['user']['permissions']
      data['session']['user'].merge!(
        'admin' => false,
        'authority_group_admin' => false,
        'kind_admin' => false,
        'relation_admin' => false
      )
      # TODO: remove this duplication in the session data
      permissions['roles'] = {
        'admin' => false,
        'authority_group_admin' => false,
        'kind_admin' => false,
        'relation_admin' => false
      }
      permissions['collections'].merge!(
        'edit' => [],
        'create' => [],
        'delete' => [],
        'tagging' => []
      )

      File.write "#{target}/session.json", to_json(data)
    end

    def settings
      data = request('/settings')

      File.write "#{target}/settings.json", to_json(data)
    end

    def statistics
      data = request('/statistics')

      File.write "#{target}/statistics.json", to_json(data)
    end

    def translations
      data = request('/translations')

      File.write "#{target}/translations.json", to_json(data)
    end

    def with_all(url, params, opts = {}, &block)
      opts.reverse_merge!(
        write: true,
        page_limit: @opts[:page_limit],
        per_page: @opts[:per_page],
        label: url
      )

      data = request("#{url}", params.merge(per_page: 1))
      pages = (data['total'] / data['per_page']).ceil
      pages = [pages, opts[:page_limit]].min if opts[:page_limit]
      pg = Kor.progress_bar opts[:label], data['total']

      (1..pages).each do |page|
        rp = params.merge(
          per_page: opts[:per_page],
          page: page
        )
        results = request(url, rp)
        results['records'].each do |record|
          yield record if block_given?

          pg.increment
        end
      end
    end

    def to_result(records)
      return {
        records: records,
        total: records.size,
        per_page: records.size,
        page: 1
      }
    end

    def apply_media_override(entity)
      return unless entity['medium']
      return unless @opts[:media_override]

      entity['medium']['url'].keys.each do |style|
        entity['medium']['url'][style] = @opts[:media_override]
      end
    end

    def media_for(entity)
      return unless entity['medium']
      apply_media_override(entity)

      apply_media_override(entity)
      return if @opts[:media_override]

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

    def delete_keys(hash, keys = [])
      keys = [keys] if !keys.is_a?(Array)
      keys.each do |k|
        hash.delete(k)
      end
    end
end
