class BaseController < ActionController::Base

  def current_user
    @current_user ||= user_by_api_key || User.pickup_session_for(session[:user_id])
  end

  def user_by_api_key
    if api_key = params[:api_key] || request.headers["api_key"]
      User.where(:api_key => api_key).first
    end
  end

end