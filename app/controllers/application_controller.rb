class ApplicationController < BaseController

  helper :all
  helper_method :back, :back_save, :home_page, 
    :authorized?,
    :allowed_to?,
    :authorized_collections,
    :authorized_for_relationship?,
    :kor_graph,
    :current_user,
    :logged_in?,
    :blaze
  
  before_filter(
    :vars, :locale, :session_expiry, :authentication, :authorization, :legal
  )

  around_filter :profile


  private

    def vars
      @messages = []
      @page = 1
      @per_page = 10
    end

    # redirects to the legal page if terms have not been accepted
    def legal
      if current_user && !current_user.guest? && !current_user.terms_accepted
        redirect_to :controller => 'static', :action => 'legal'
      end
    end

    rescue_from StandardError do |exception|
      if Rails.env == 'production'
        Kor::ExceptionLogger.log exception, params: params
      else
        raise exception
      end

      # respond_to do |format|
      #   format.html {raise exception}
      #   format.json {
      #     if Rails.env.test?
      #       raise exception
      #     else
      #       render status: 500, json: {
      #         'message' => exception.message,
      #         'backtrace' => exception.backtrace
      #       }
      #     end
      #   }
      # end
    end

    def session_expiry
      if session_expired?
        @messages << I18n.t('notices.session_expired')
        session[:user_id] = nil
      else
        session[:expires_at] = Kor.session_expiry_time
      end
    end
    
    def authentication
      session[:user_id] ||= if User.guest
        session[:expires_at] = Kor.session_expiry_time
        User.guest.id
      end

      if !current_user
        render_403
      else
        Rails.logger.info("Auth: user '#{current_user.name}' has been seen")
      end
    end
    
    def authorization
      unless generally_authorized?
        render_403
      end
    end

    def session_expired?
      if !current_user.guest? && !api_auth?
        !!(session[:expires_at] && (session[:expires_at] < Time.now))
      end
    end

    def api_auth?
      if @api_auth == nil
        key = params[:api_key] || request.headers['api_key']
        @api_auth = (key && User.exists?(api_key: key))
      end

      @api_auth
    end
    
    def generally_authorized?
      true
    end
    
    
  protected

    def locale
      if current_user && current_user.locale
        I18n.locale = current_user.locale
      else
        I18n.locale = Kor.config['locale'] || I18n.default_locale
      end
    end

    def authorized?(policy = :view, collections = nil, options = {})
      @auth_cache ||= {}
      options.reverse_merge!(required: :any, cache: @auth_cache)
      Kor::Auth.allowed_to? current_user, policy, collections, options
    end

    def authorized_collections(policy)
      Kor::Auth.authorized_collections current_user, policy
    end
    
    def viewable_entities
      Entity.allowed current_user, :view
    end
    
    def editable_entities
      Entity.allowed current_user, :edit
    end

    def param_to_array(value, options = {})
      options.reverse_merge! ids: true

      case value
        when String
          results = value.split(',')
          options[:ids] ? results.map{|v| v.to_i} : results
        when Fixnum then [value]
        when Array then value.map{|v| param_to_array(v, options)}.flatten
        when nil then []
        else
          raise "unknown param format to convert to array: #{value}"
      end
    end
    
    def authorized_for_relationship?(relationship, policy = :view)
      if relationship.to && relationship.from
        case policy
          when :view
            view_from = authorized?(:view, relationship.from.collection)
            view_to = authorized?(:view, relationship.to.collection)
            
            view_from and view_to
          when :create, :delete, :edit
            view_from = authorized?(:view, relationship.from.collection)
            view_to = authorized?(:view, relationship.to.collection)
            edit_from = authorized?(:edit, relationship.from.collection)
            edit_to = authorized?(:edit, relationship.to.collection)
            
            (view_from and edit_to) or (edit_from and view_to)
          else
            false
        end
      else
        true
      end
    end

    def allowed_to?(policy = :view, collections = Collection.all, options = {})
      authorized?(policy, collections, options)
    end
    
    def user_groups
      UserGroup.owned_by(current_user)
    end
    
    def history_store(url = nil)
      url ||= request.url
      if current_user && !current_user.guest?
        current_user.history_push url
      end
    end
    
    def back
      if current_user && !current_user.guest?
        current_user.history_pop
      end
    end
    
    def back_save
      back || home_page || root_url
    end
    
    def home_page
      (current_user ? current_user.home_page : nil ) || root_url
    end
    
    def logged_in?
      current_user && current_user.name != 'guest'
    end
    
    def kor_graph
      @kor_graph ||= Kor::Graph.new(:user => current_user)
    end

    def current_entity
      session[:current_entity]
    end

    def entity_params
      params.require(:entity).permit(
        :lock_version,
        :kind_id,
        :collection_id,
        :name, :distinct_name, :subtype, :comment, :no_name_statement,
        :tag_list,
        :synonyms => [],
        :datings_attributes => [:id, :_destroy, :label, :dating_string],
        :dataset => params[:entity][:dataset].try(:keys),
        :properties => [:label, :value],
        :medium_attributes => [:id, :image, :document]
      ).tap do |e|
        e[:properties] ||= []
        e[:synonyms] ||= []
      end
    end

    def profile
      if ENV["PROFILE"]
        require 'perftools'
        path = request.path.gsub("/", "_")
        path = "#{Rails.root}/tmp/profiles/#{path}"
        PerfTools::CpuProfiler.start(path) do
          yield
        end
      else
        yield
      end
    end

    def render_messages(messages, status)
      @messages += messages
      render status: status, action: '../api/message'
    end

    def render_403(message = nil)
      message ||= I18n.t('notices.access_denied')
      render_messages [message], 403
    end

    def render_404(message)
      render_messages [message], 404
    end

    def render_406(message = nil)
      message ||= I18n.t('activemodel.errors.template.header')
      render_messages [message], 406
    end

    def render_200(message)
      render_messages [message], 200
    end

    # def browser_path(path = '')
    #   "#{root_path}##{path}"
    # end

end
