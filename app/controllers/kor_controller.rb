class KorController < JsonController
  skip_before_action :authentication, :authorization, :legal

  def index
    # just a dummy
    render nothing: true
  end
  
  def info
    
  end

  def statistics
    
  end

  def translations
    I18n.backend.load_translations
    render json: {'translations' => I18n.backend.send(:translations)}
  end
end
