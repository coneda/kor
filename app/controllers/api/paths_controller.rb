class Api::PathsController < Api::ApiController

  def index
    @paths = kor_graph.find_paths(params[:specs])
    @paths = kor_graph.load(@paths)

    render :json => @paths
  end

  def gallery
    @paths = []

    @paths += kor_graph.find_paths [
      {'id' => params[:id]},
      {'name' => Kor.config["app.gallery.primary_relations"]},
      {}
    ]

    @paths += kor_graph.find_paths [
      {'id' => params[:id]},
      {'name' => Kor.config["app.gallery.primary_relations"]},
      {},
      {'name' => Kor.config["app.gallery.secondary_relations"]},
      {}
    ]
    @paths = kor_graph.load(@paths)

    render :json => @paths.as_json(:root => false)
  end


  protected

    def authorized?
      true
    end

end