class MainController < JsonController
  
  skip_before_action :authentication, :authorization, :legal
  
  # TODO: implement as ajax
  def welcome
    @title = Kor.config['app.welcome_title']
    @red_cloth = RedCloth.new(Kor.config['app.welcome_text'] || "")
    @red_cloth.sanitize_html = true
    
    @entities = kor_graph.search(:random).results
  end

  def info

  end

  # TODO: make this more selective as it might contain confidential data
  def kor_config
    @raw = Kor.config.raw
    @raw['maintainer']['legal_html'] = RedCloth.new(@raw['maintainer']['legal_text']).to_html
    @raw['maintainer']['about_html'] = RedCloth.new(@raw['maintainer']['about_text']).to_html
    @raw['app']['welcome_html'] = RedCloth.new(@raw['app']['welcome_text']).to_html

    render json: {'config' => @raw}
  end

  # TODO: implement as ajax
  def statistics

  end

  def translations
    I18n.backend.load_translations
    render json: {'translations' => I18n.backend.send(:translations)}
  end
  
end
