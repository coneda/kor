class Kor::Graph::Search::Query::Gallery < Kor::Graph::Search::Query::Base

  # Constructor
  
  def initialize(user, options = {})
    options.reverse_merge!(
      :media => false,
      :per_page => 16
    )
        
    super user, options
  end
  
  
  # Processing

  private

    def execute
      result = Entity.allowed(user, :view).load_fully.newest_first
      
      @total = result.count
      
      result.newest_first.paginate(:page => page, :per_page => per_page).to_a
    end
  
end
