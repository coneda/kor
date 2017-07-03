class BaseController < ActionController::Base

  if Rails.env.production?
    protect_from_forgery with: :null_session
  else
    protect_from_forgery with: :exception
  end

  helper_method(
    :current_user, :logged_in?,
    :authorized?, :allowed_to?, :authorized_collections,
    :authorized_for_relationship?
  )


  protected

    def current_user
      @current_user ||= user_by_api_key || User.pickup_session_for(session[:user_id])
    end

    def user_by_api_key
      api_key = 
        params[:api_key] ||
        request.headers["HTTP_API_KEY"] ||
        request.headers["API_KEY"]

      if api_key
        User.where(:api_key => api_key).first
      end
    end

    def authorized?(policy = :view, collections = nil, options = {})
      options.reverse_merge!(:required => :any)
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
    
    def logged_in?
      current_user && current_user.name != 'guest'
    end

end