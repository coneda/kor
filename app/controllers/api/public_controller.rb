class Api::PublicController < BaseController

  before_action :session_expiry
  
  def info
    @current_entities = Entity.
      includes(:medium).
      by_ordered_id_array(session[:current_history])

    I18n.backend.load_translations
  end
    
end
