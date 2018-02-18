class ApplicationController < BaseController

  helper :all
  helper_method :back, :back_save, :home_page, :kor_graph
  
  before_filter(
    :vars, :locale, :session_expiry, :authentication, :authorization, :legal
  )

  around_filter :profile


  private

    def vars
      @messages = []
      @page = params[:page] || 1
      @per_page = params[:per_page] || 10
    end

    # redirects to the legal page if terms have not been accepted
    def legal
      if current_user && !current_user.guest? && !current_user.terms_accepted
        redirect_to :controller => 'static', :action => 'legal'
      end
    end

    rescue_from ActiveRecord::RecordNotFound, with: :render_404

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
      render_403 unless generally_authorized?
    end

    def render_403
      respond_to do |format|
        format.html do
          flash[:error] = I18n.t('notices.access_denied')
          render template: 'authentication/denied', status: 403
        end
        format.json do
          render json: {message: I18n.t('notices.access_denied')}, status: 403
        end
      end
    end

    def render_404
      render 'layouts/404', status: 404
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

    def param_to_array(value, options = {})
      options.reverse_merge! ids: true

      case value
        when String
          results = value.split(',')
          options[:ids] ? results.map{|v| v.to_i} : results
        when Integer then [value]
        when Array then value.map{|v| param_to_array(v, options)}.flatten
        when nil then []
        else
          raise "unknown param format to convert to array: #{value}"
      end
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
        :new_datings_attributes => [
          :id, :_destroy, :label, :dating_string, :lock_version
        ],
        :existing_datings_attributes => [
          :id, :_destroy, :label, :dating_string, :lock_version
        ],
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
