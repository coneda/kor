class Kor::Graph::Search::Query::List < Kor::Graph::Search::Query::Base

  # Constructor

  def initialize(user, options)
    options.reverse_merge!(:media => false)
        
    super
  end
  
  
  # Processing
  
  private
  
    def execute
      result = Entity.allowed(user, :view).alphabetically
      options[:media] ? result : result.searcheable
    end
  
end
