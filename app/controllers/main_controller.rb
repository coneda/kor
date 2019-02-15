class MainController < ApplicationController
  
  layout 'wide'
  
  def welcome
    @title = Kor.config['app.welcome_title']
    @red_cloth = RedCloth.new(Kor.config['app.welcome_text'] || "")
    
    @entities = kor_graph.search(:random).results
  end
  
end
