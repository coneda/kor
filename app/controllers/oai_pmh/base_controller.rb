class OaiPmh::BaseController < BaseController
  layout "../oai_pmh/base"

  respond_to :xml

  helper_method :timestamp, :base_url # , :medium_url

  skip_before_filter :verify_authenticity_token
  before_filter :ensure_metadata_prefix, only: [:get_record, :list_records]
  before_filter :handle_resumption_token, only: [:list_identifiers, :list_records]

  def identify
    @admin_email = User.admin.email
    @earliest_timestamp = earliest_timestamp

    render :template => "oai_pmh/identify"
  end

  def list_sets
    render_error 'noSetHierarchy'
  end

  def list_metadata_formats
    render :template => "oai_pmh/list_metadata_formats"
  end

  def list_identifiers
    record_params = params.select do |k, _v|
      ["metadataPrefix", "from", "to", "set", "resumptionToken", 'page', 'per_page'].include?(k)
    end

    @records = query(record_params)

    if @records[:total] > 0
      render :template => "oai_pmh/list_identifiers"
    else
      render_error 'noRecordsMatch'
    end
  end

  def list_records
    record_params = params.select do |k, _v|
      ["metadataPrefix", "from", "to", "set", "resumptionToken", 'page', 'per_page'].include?(k)
    end

    @records = query(record_params)

    if @records[:total] > 0
      render :template => "oai_pmh/list_records"
    else
      render_error 'noRecordsMatch'
    end
  end

  def verb_error
    render_error 'badVerb'
  end

  protected

    def ensure_metadata_prefix
      available = ["kor", "oai_dc"]
      unless available.include?(params[:metadataPrefix])
        render_error 'cannotDisseminateFormat'
      end
    end

    def handle_resumption_token
      if params['resumptionToken']
        if token_data = load_query(params['resumptionToken'])
          params.merge! token_data.merge(params)
          params['page'] += 1
        else
          render_error 'badResumptionToken'
        end
      end
    end

    def render_error(code, description = nil)
      @code = code
      @description = description

      respond_to do |format|
        format.xml do
          render template: 'oai_pmh/error', status: 400, layout: '../oai_pmh/base'
        end
      end
    end

    # def medium_url(medium, style = :preview)
    #   (root_url + medium.url(style)).gsub '//', '/'
    # end

    def query(params = {})
      params['per_page'] ||= 50
      params['page'] ||= 0
      param_from = Time.parse(params['from']) if params['from']
      param_until = Time.parse(params['until']) if params['until']

      scope = records.
        allowed(current_user, :view).
        updated_after(param_from).
        updated_before(param_until)

      offset_scope = scope.offset(params['page'] * params['per_page'])

      # token = if offset_scope.count > params['per_page']
      token = if scope.count - params['page'] * params['per_page'] > params['per_page']
        dump_query(params)
      elsif params['resumptionToken']
        ''
      end

      {
        :items => offset_scope.limit(params['per_page']),
        :token => token,
        :total => scope.count
      }
    end

    def base_dir
      "#{Rails.root}/tmp/resumption_tokens"
    end

    def dump_query(params)
      system "mkdir -p #{base_dir}"
      token = SecureRandom.hex(20)

      Kor.with_exclusive_lock 'oai_pmh_tokens' do
        Dir["#{base_dir}/*.json"].each do |f|
          if File.stat(f).mtime < 3.minutes.ago
            File.delete(f)
          end
        end
      end

      File.open "#{base_dir}/#{token}.json", "w" do |f|
        data = {}
        ['page', 'per_page', 'from', 'until', 'set'].each do |k|
          data[k] = params[k] if params[k]
        end
        f.write JSON.dump(data)
      end

      token
    end

    def load_query(token)
      file = "#{base_dir}/#{token}.json"

      if File.exist?(file)
        JSON.parse(File.read file)
      end
    end

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
      oai_pmh_entities_url
    end
end
