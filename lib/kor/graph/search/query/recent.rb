class Kor::Graph::Search::Query::Recent < Kor::Graph::Search::Query::Base

  define_params(collection_id: nil)

  private

    def execute
      scope = Entity.
        includes(:creator, :updater, :collection, :kind, :tags).
        allowed(@user, :edit).
        without_media.
        newest_first.
        within_collections(criteria[:collection_id])

      @total = scope.count

      scope.pageit(page, per_page)
    end

end