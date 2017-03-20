class BaseController < ActionController::Base

  if Rails.env.production?
    protect_from_forgery with: :null_session
  else
    protect_from_forgery with: :exception
  end

  helper_method :current_user

  def current_user
    @current_user ||= user_by_api_key || User.pickup_session_for(session[:user_id])
  end

  def user_by_api_key
    if api_key = params[:api_key] || request.headers["api_key"]
      User.where(:api_key => api_key).first
    end
  end

  def session_expiry
    if session_expired?
      session[:user_id] = nil
      @current_user = nil
    end
  end

  def session_expired?
    if current_user && !current_user.guest? && !api_auth?
      !!(session[:expires_at] && (session[:expires_at] < Time.now))
    end
  end

  def api_auth?
    key = params[:api_key] || request.headers['api_key']
    key && User.exists?(api_key: key)
  end

end