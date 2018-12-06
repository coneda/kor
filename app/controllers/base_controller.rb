class BaseController < ActionController::Base
  if Rails.env.production?
    protect_from_forgery with: :null_session, unless: :api_auth?
  else
    protect_from_forgery with: :exception, unless: :api_auth?
  end

  before_filter :reload_settings, :set_default_url_options, :locale
  before_filter :session_expiry, unless: :api_auth?

  if ENV['PROFILE']
    require 'perftools'
    around_filter :profile
  end

  # TODO: refactor authorized objects stuff to somewhere else?
  helper_method(
    :current_user,
    :allowed_to?,
    :authorized_for_relationship?,
    :medium_url
  )

  protected

    def current_user
      @current_user ||= 
        user_by_api_key || 
        User.pickup_session_for(session[:user_id]) ||
        User.guest
    end

    def user_by_api_key
      api_key = 
        params[:api_key] ||
        request.headers['HTTP_API_KEY'] ||
        request.headers['API_KEY'] ||
        request.headers['api_key']

      if api_key
        User.find_by(api_key: api_key)
      end
    end

    def api_auth?
      !!user_by_api_key
    end

    def authorized_for_relationship?(relationship, policy = :view)
      Kor::Auth.authorized_for_relationship?(current_user, relationship, policy)
    end

    def allowed_to?(policy = :view, collections = Collection.all, options = {})
      Kor::Auth.allowed_to? current_user, policy, collections, options
    end
    
    # TODO: test this
    def session_expiry
      if session_expired?
        session[:user_id] = nil
        @current_user = nil
      else
        session[:expires_at] = Kor.session_expiry_time
      end
    end

    # TODO: test this
    def session_expired?
      if current_user && !current_user.guest?
        session[:expires_at] ||= Kor.session_expiry_time
        session[:expires_at] < Time.now
      end
    end

    def locale
      if current_user && current_user.locale
        I18n.locale = current_user.locale
      else
        I18n.locale = Kor.settings['locale'] || I18n.default_locale
      end
    end

    def profile
      path = request.path.gsub("/", "_")
      path = "#{Rails.root}/tmp/profiles/#{path}"
      PerfTools::CpuProfiler.start(path) do
        yield
      end
    end

    def set_default_url_options
      opts = Kor.default_url_options(request)
      ActionMailer::Base.default_url_options = opts
    end

    def reload_settings
      Kor.settings.ensure_fresh
    end

    def medium_url(medium, options = {})
      options.reverse_merge!(
        root: false,
        style: :original,
        download: false
      )

      if Rails.env.development? && !ENV['SHOW_MEDIA']
        return medium.dummy_url
      end

      result = if options[:style] == :original
        medium.document.url(:original)
      elsif image_style?(options[:style])
        medium.image.url(options[:style])
      else
        medium.custom_style_url(options[:style])
      end

      if options[:download]
        result = result.gsub /\/images\//, '/download/'
      end

      if options[:root]
        root_url.gsub(/\/$/, '') + result
      else
        result
      end
    end
end