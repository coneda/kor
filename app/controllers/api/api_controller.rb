class Api::ApiController < ActionController::Base

  respond_to :json

  before_filter do
    if require_user? && !current_user
      render_error :not_authenticated, 401
    else
      unless authorized?
        render_error :not_authorized, 403
      end
    end
  end

  protected

    def current_user
      @current_user ||= User.find_by_id(session[:user_id])# || User.find_by_api_key(params[:key])
    end
    
    def require_user?
      true
    end
    
    def authorized?
      false
    end
    
    def render_notice(notice, status = 200)
      render_error(notice, status)
    end
    
    def render_error(error, status = 400)
      render :json => {:message => error_messages[error]}, :status => status
    end
    
    def error_messages
      return {
        :not_authenticated => "You are not authentiated please provide a key or authenticate via /login first",
        :not_authorized => "You are not authorized to call this method",
        :bad_credentials => "The username or password is incorrect",
        :already_authenticated => "You are already logged in",
        :authenticated => "You are now logged in",
        :logged_out => "You have been logged out"
      }
    end
    
    def authorized_collections(policy = :view, out_of = nil)
      out_of ||= Collection.all.map{|c| c.id}
      out_of = out_of.map{|id| id.to_i}
      result = Auth::Authorization.authorized_collections current_user, policy
      result.select do |c|
        out_of.include? c.id
      end
    end
  
end
