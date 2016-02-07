class ApplicationController < ActionController::Base
  
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
  
  before_filter :locale, :authentication, :authorization, :legal

  before_filter do
    @blaze = nil
  end
  

  private

    # redirects to the legal page if terms have not been accepted
    def legal
      if current_user && !current_user.guest? && !current_user.terms_accepted
        redirect_to :controller => 'static', :action => 'legal'
      end
    end

    # this method is called, when an exception ocurred while generating a
    # response to a request which wasn't sent from localhost
    
    if Rails.env == 'production'
      rescue_from Exception, :with => :log_exception_and_notify_user
      rescue_from ActionController::RoutingError, :with => :not_found
      rescue_from ActiveRecord::RecordNotFound, :with => :not_found
    end
    
    def not_found
      redirect_to '/404.html'
    end

    def log_exception_and_notify_user(exception)
      ExceptionLog.create(
        :kind => exception.class.to_s,
        :message => exception.message,
        :backtrace => exception.backtrace,
        :params => params
      )
      
      redirect_to '/500.html'
    end

    def authentication
      session[:user_id] ||= if User.guest
        session[:expires_at] = Kor.session_expiry_time
        User.guest.id
      end
      
      if !current_user
        respond_to do |format|
          format.html do
            unless controller_name.match(/tpl/)
              history_store
            end
            redirect_to login_path
          end
          format.json do
            render :json => {:notice => I18n.t('notices.access_denied')}, :status => 403
          end
        end
      elsif session_expired?
        respond_to do |format|
          # TODO: this is working but strictly speaking not correct behavior:
          # no session data should persist through an expired session
          session[:user_id] = nil

          format.html do
            history_store unless request.path.match(/^\/blaze/)
            flash[:notice] = I18n.t('notices.session_expired')
            redirect_to login_path
          end
          format.json do
            render :json => {:notice => I18n.t('notices.session_expired')}, :status => 403
          end
        end
      else
        Kor.info("AUTH", "user '#{current_user.name}' has been seen")
        session[:expires_at] = Kor.session_expiry_time
      end
    end
    
    def authorization
      unless generally_authorized?
        flash[:error] = I18n.t('notices.access_denied')
        redirect_to denied_path
      end
    end

    def session_expired?
      unless current_user.guest?
        (session[:expires_at] || Time.now) <= Time.now
      end
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
      options.reverse_merge!(:required => :any)
      Kor::Auth.authorized? current_user, policy, collections, options
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
    
    def authorized_for_relationship?(relationship, policy = :view)
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
    end

    def allowed_to?(policy = :view, collections = Collection.all, options = {})
      authorized?(policy, collections, options)
    end
    
    def user_groups
      UserGroup.owned_by(current_user)
    end
    
    def history_store(url = nil)
      url ||= request.url
      session[:history] ||= []
      if url.present? && url != root_url
        session[:history] << url 
      end
      session[:history].shift if session[:history].size > 20
    end
    
    def back
      session[:history] ||= []
      session[:history].pop
    end
    
    def cleanup_history
      session[:history] = (session[:history] || []).select do |url|
        if url.match /\/(entities|blaze)\/[0-9]+$/
          id = url.scan(/[0-9]+$/).first
          Entity.exists?(id)
        end
      end
    end
    
    def back_save
      cleanup_history
      back || home_page || root_url
    end
    
    def home_page
      current_user.home_page || root_url
    end
    
    def current_user
      @current_user ||= User.pickup_session_for(session[:user_id])
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

    def blaze
      @blaze ||= Kor::Blaze.new(current_user)
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
        :new_datings_attributes => [:id, :_destroy, :label, :dating_string],
        :existing_datings_attributes => [:id, :_destroy, :label, :dating_string],
        :dataset => params[:entity][:dataset].try(:keys),
        :properties => [:label, :value],
        :medium_attributes => [:image, :document]
      )
    end

end
