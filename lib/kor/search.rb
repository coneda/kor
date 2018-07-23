class Kor::Search
  def initialize(criteria = {})
    @criteria = criteria
    run
  end

  def run
    @scope = Entity.
      alphabetically.
      within_collections(@criteria[:collection_id]).
      only_kinds(@criteria[:kind_id]).
      named_like(@criteria[:name])

    if @criteria[:no_media]
      @scope = @scope.without_media
    end
  end

  def records
    @scope.pageit(@criteria[:page], @criteria[:per_page])
  end

  def total
    @scope.count
  end
end