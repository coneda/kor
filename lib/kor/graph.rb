class Kor::Graph
  
  # Constructor
  
  def initialize(options = {})
    @options = options
  end
  
  
  # Main
  
  def search(type, options = {})
    Kor::Graph::Search.create(type, user, options)
  end
  
  def results_from(object)
    Kor::Graph::Search::Result.from(object)
  end
  
  
  # Accessors
  
  def user
    @options[:user]
  end
  
end
