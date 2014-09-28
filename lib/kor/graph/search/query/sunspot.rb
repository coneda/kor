class Kor::Graph::Search::Query::Sunspot < Kor::Graph::Search::Query::Base
  
  # Constructor
  
  def initialize(user, options = {})
    options.reverse_merge!(:media => false)
        
    super user, options
  end
  
  
  # Parameters
  
  define_params(
    :terms => [], 
    :kind_id => nil, 
    :tags => []
  )
  
  
  # Main
  
  def ids
    items.map{|i| i.id}
  end
  
  def items
    run
    @sunspot.results
  end
  
  def total
    run
    @sunspot.total
  end
  
  
  # Processing

  private
  
    def execute
      criteria[:terms] ||= []
      criteria[:terms] = [criteria[:terms]] unless criteria[:terms].is_a?(Array)

      terms = criteria[:terms].map do |t|
        result = t.gsub /(^.\s+)|(\s+.\s+)|(\s+.$)/, ''
        "*\"#{result}\"*"
      end

      terms = terms.map! do |t|
        Splitter.new(t).tokenize.join(' ')
      end

      terms = terms.join ' '

      @sunspot = Sunspot.search(Entity) do
        keywords(terms) unless terms.blank?
        with(:kind_id, criteria[:kind_id]) unless criteria[:kind_id].blank?
        without(:kind_id, Kind.medium_kind.id)
        with(:tags).all_of(criteria[:tags]) unless criteria[:tags].blank?

        any_of do
          with(:collection_id, authorized_collection_ids) unless authorized_collection_ids.empty?
        end
        
        paginate :page => page, :per_page => per_page
      end
    end
  
end
