module Kor::Graph::Search

  def self.create(type, user, options = {})
    Kor::Graph::Search::Query.create(type, user, options)
  end

end
