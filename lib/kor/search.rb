class Kor::Search
  def initialize(user, criteria = {})
    @user = user
    @criteria = criteria
    run
  end

  def run
    @scope = Entity.
      allowed(@user, @criteria[:policy] || :view).
      alphabetically.
      within_collections(@criteria[:collection_id]).
      only_kinds(@criteria[:kind_id]).
      named_like(@criteria[:name]).
      by_id(@criteria[:id])

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