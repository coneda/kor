module Kor::Graph::Search::Query
  
  def self.create(type, user, options = {})
    "Kor::Graph::Search::Query::#{type.to_s.classify}".constantize.new(user, options)
  end
  
end
