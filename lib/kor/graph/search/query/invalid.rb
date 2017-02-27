class Kor::Graph::Search::Query::Invalid < Kor::Graph::Search::Query::Base

  define_params(collection_id: nil)

  private

    def execute
      group = SystemGroup.find_or_create_by(name: 'invalid')
      scope = group.entities.allowed(@user, :delete)

      @total = scope.count

      scope.pageit(page, per_page)
    end

end