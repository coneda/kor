class ApplicationController < BaseController

  helper :all
  helper_method :back, :back_save, :home_page, :kor_graph
  
  before_filter(
    :authorization
  )

  private

    # def authorization
    #   render_403 unless generally_authorized?
    # end

    # def render_403
    #   respond_to do |format|
    #     format.html do
    #       flash[:error] = I18n.t('notices.access_denied')
    #       render template: 'authentication/denied', status: 403
    #     end
    #     format.json do
    #       render json: {message: I18n.t('notices.access_denied')}, status: 403
    #     end
    #   end
    # end

    # def render_404
    #   render 'layouts/404', status: 404
    # end

    # def generally_authorized?
    #   true
    # end
    
  protected

    # TODO: probably not needed anymore
    # def user_groups
    #   UserGroup.owned_by(current_user)
    # end
    
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
    
    # def kor_graph
    #   @kor_graph ||= Kor::Graph.new(:user => current_user)
    # end

    # def current_entity
    #   session[:current_entity]
    # end

    # def browser_path(path = '')
    #   "#{root_path}##{path}"
    # end

end
