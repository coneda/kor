class Kor::Graph::Search::Query::Gallery < Kor::Graph::Search::Query::Base

  # Constructor
  
  def initialize(user, options = {})
    options.reverse_merge!(
      :media => false,
      :per_page => 16
    )
        
    super user, options
  end
  
  
  # Parameters
  
  define_params(
    :terms => nil
  )
  
  
  # Processing

  private

    def execute
      criteria[:terms] ||= ""
      result = Entity.allowed(user, :view).load_fully.gallery(criteria[:terms]).newest_first
      
      @total = result.count
      
      result.newest_first.paginate(:page => page, :per_page => per_page).to_a
    end
  
end
