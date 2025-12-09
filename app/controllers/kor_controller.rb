class KorController < JsonController
  skip_before_action :legal

  def index
    # just a dummy
    render nothing: true, layout: false
  end

  def info
  end

  def statistics
  end

  def translations
    I18n.backend.load_translations
    render json: {'translations' => I18n.backend.send(:translations)}
  end

  def api
    html_file = "#{Rails.root}/public/api.html"

    unless File.exist?(html_file)
      Kor::Tasks.build_api_docs
    end

    render file: html_file
  end
end
