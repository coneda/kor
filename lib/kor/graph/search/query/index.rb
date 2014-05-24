class Kor::Graph::Search::Query::Index < Kor::Graph::Search::Query::Base
  
  # Constructor
  
  def initialize(user, options = {})
    options.reverse_merge!(:media => false)
        
    super user, options
  end
  
  
  # Parameters
  
  define_params(
    :terms => nil, 
    :kind_id => nil, 
    :tags => []
  )
  
  
  # Main
  
  def ids
    run
  end
  
  def items
    Entity.find_all_by_id_keep_order(ids)
  end
  
  
  # Processing

  private

    def execute
      index = Kor::SimpleSearchIndex.new
      
      index.synchronize do
        top_docs = index.search(user, criteria, page - 1, per_page)
        @total = top_docs.total_hits
        top_docs.hits.map{|h| index.index[h.doc][:id]}
      end
    end
  
end
