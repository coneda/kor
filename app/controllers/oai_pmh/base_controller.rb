class OaiPmh::BaseController < BaseController
  layout "oai_pmh/base"

  respond_to :xml

  helper_method :timestamp, :base_url # , :medium_url

  skip_before_action :verify_authenticity_token

  before_action :handle_resumption_token, only: [:list_identifiers, :list_records]
  before_action :ensure_metadata_prefix, only: [:get_record, :list_records]
  before_action :ensure_datestamp_format, only: [:list_identifiers, :list_records]
  before_action :ensure_identifier, only: [:get_record]

  def identify
    @admin_email = Kor.settings['maintainer_mail']
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
      ["metadataPrefix", "from", "until", "set", "resumptionToken", 'page', 'per_page'].include?(k)
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
      ["metadataPrefix", "from", "until", "set", "resumptionToken", 'page', 'per_page'].include?(k)
    end

    @records = query(record_params)

    if @records[:total] > 0
      render template: "oai_pmh/list_records"
    else
      render_error 'noRecordsMatch'
    end
  end

  def verb_error
    render_error 'badVerb'
  end

  protected

    def ensure_metadata_prefix
      if params[:metadataPrefix].present?
        available = ["kor", "oai_dc"]
        unless available.include?(params[:metadataPrefix])
          render_error 'cannotDisseminateFormat'
        end
      else
        render_error 'badArgument', 'metadataPrefix has to be supplied'
      end
    end

    def handle_resumption_token
      if params['resumptionToken']
        if token_data = load_query(params['resumptionToken'])
          mm = token_data.merge(params.permit!.to_h)
          params.merge! mm
          params['page'] += 1
        else
          render_error 'badResumptionToken'
        end
      end
    end

    def ensure_datestamp_format
      regex = /^\d\d\d\d-\d\d-\d\dT\d\d:\d\d:\d\dZ$/

      if params[:from].present? && !params[:from].match(regex)
        render_error 'badArgument', 'from has incorrect format'
      end

      if params[:until].present? && !params[:until].match(regex)
        render_error 'badArgument', 'until has incorrect format'
      end
    end

    def ensure_identifier
      unless params[:identifier].present?
        render_error 'badArgument', 'identifier must be supplied'
      end
    end

    def render_error(code, description = nil)
      @code = code
      @description = description

      respond_to do |format|
        format.xml do
          render template: 'oai_pmh/error', layout: 'oai_pmh/base'
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
      token = if scope.count - (params['page'] * params['per_page']) > params['per_page']
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
        ['page', 'per_page', 'from', 'until', 'set', 'metadataPrefix'].each do |k|
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
