class MainController < ApplicationController
  
  # TODO: remove this and all others like it
  layout 'wide'

  skip_before_action :authentication, :authorization, :legal
  
  def welcome
    @title = Kor.config['app.welcome_title']
    @red_cloth = RedCloth.new(Kor.config['app.welcome_text'] || "")
    @red_cloth.sanitize_html = true
    
    @entities = kor_graph.search(:random).results
  end

  def info

  end

  def kor_config
    # TODO: make this more selective as it might contain confidential data
    @raw = Kor.config.raw
    @raw['maintainer']['legal_html'] = RedCloth.new(@raw['maintainer']['legal_text']).to_html

    render json: {'config' => @raw}
  end

  def statistics

  end

  def translations
    I18n.backend.load_translations
    render json: {'translations' => I18n.backend.send(:translations)}
  end
  
end
