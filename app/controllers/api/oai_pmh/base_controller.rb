class Api::OaiPmh::BaseController < BaseController

  layout "../api/oai_pmh/base"

  respond_to :xml

  helper_method :timestamp, :base_url, :medium_url

  def identify
    @admin_email = User.admin.email
    @earliest_timestamp = earliest_timestamp

    render :template => "api/oai_pmh/identify"
  end

  def list_sets
    render :template => "api/oai_pmh/list_sets"
  end

  def list_metadata_formats
    render :template => "api/oai_pmh/list_metadata_formats"
  end

  def list_identifiers
    record_params = params.select do |k, v|
      ["metadataPrefix", "from", "to", "set", "resumptionToken"].include?(k)
    end

    @records = query(record_params)

    render :template => "api/oai_pmh/list_identifiers"
  end

  def list_records
    record_params = params.select do |k, v|
      ["metadataPrefix", "from", "to", "set", "resumptionToken"].include?(k)
    end

    @records = query(record_params)

    render :template => "api/oai_pmh/list_records"
  end


  protected

    def medium_url(medium, style = :preview)
      (root_url + medium.url(style)).gsub '//', '/'
    end

    def query(params = {})
      params['per_page'] = 50
      params['page'] = 0

      if params["resumptionToken"]
        params = load_query(params["resumptionToken"])
        params["page"] += 1
      end

      scope = records.
        allowed(current_user, :view).
        updated_after(params['from']).
        updated_before(params['until'])

      offset_scope = scope.offset(params['page'] * params['per_page'])

      token = if offset_scope.count > params['per_page']
        dump_query(params)
      end

      {
        :items => offset_scope.limit(params['per_page']),
        :token => token,
        :total => scope.count
      }
    end

    def dump_query(params)
      token = Digest::SHA1.hexdigest("resumptionToken #{Time.now} #{rand}")
      base_dir = "#{Rails.root}/tmp/resumption_tokens"
      system "mkdir -p #{base_dir}"
      system "find #{base_dir} -mtime +1 -exec rm {} \;"

      File.open "#{base_dir}/#{token}.json", "w+" do |f|
        f.write JSON.dump(params)
      end

      token
    end

    def load_query(token)
      base_dir = "#{Rails.root}/tmp/resumption_tokens"
      file = "#{base_dir}/#{token}.json"

      if File.exists?(file)
        JSON.parse(File.read file)
      end
    end

    # def collections
    #   Auth::Authorization.authorized_collections(current_user, :view)
    # end

    def locate(identifier)
      records.where(:uuid => identifier).first
    end

    def earliest_timestamp
      Time.now
    end

    def timestamp(value = nil)
      value ||= Time.now
      value.utc.strftime "%Y-%m-%dT%H:%M:%SZ"
    end

    def base_url
      api_oai_pmh_entities_url
    end

    def current_user
      super || User.guest
    end

end