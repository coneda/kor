class MainController < ApplicationController
  
  layout 'wide'
  
  def welcome
    @title = Kor.config['app.welcome_title']
    @red_cloth = RedCloth.new(Kor.config['app.welcome_text'] || "")
    @red_cloth.sanitize_html = true
    
    @entities = kor_graph.search(:random).results
  end

  def info

  end

  def kor_config
    render json: Kor.config.raw
  end

  def statistics

  end

  def translations
    I18n.backend.load_translations
    render json: I18n.backend.send(:translations)
  end
  
end
