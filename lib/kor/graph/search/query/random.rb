class Kor::Graph::Search::Query::Random < Kor::Graph::Search::Query::Base
  
  # Accessors
  
  def total
    items.size
  end
  
  
  # Parameters
  
  define_params(:limit => 4)
  
    
  # Processing

  private
  
    def viewable_media_entities
      Entity.allowed(user, :view).media
    end

    def execute
      Random.srand
      c = viewable_media_entities.count
      
      if c < limit
        viewable_media_entities.all
      else
        o = 0
        Array.new(limit).map do |i|
          o += [(rand(c) / limit).round, 1].max
          viewable_media_entities.limit(1).offset(o).load_fully.to_a.first
        end
      end
    end
  
end
