class Api::PublicController < BaseController
  
  def info
    @current_entities = Entity.
      includes(:medium).
      find_all_by_id_keep_order(session[:current_history])

    I18n.backend.load_translations
  end
    
end
