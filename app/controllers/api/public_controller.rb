class Api::PublicController < Api::ApiController
  
  def info
    @current_entities = Entity.
      includes(:medium).
      find_all_by_id_keep_order(session[:current_history])
  end
  

  protected
  
    def require_user?
      false
    end
    
    def authorized?
      true
    end
    
end
