class Kor::Search
  def initialize(user, criteria = {})
    @user = user
    @criteria = criteria
    run
  end

  def run
    @scope = Entity.
      allowed(@user, @criteria[:policy] || :view).
      within_collections(@criteria[:collection_id]).
      within_authority_groups(@criteria[:authority_group_id]).
      only_kinds(@criteria[:kind_id]).
      except_kinds(@criteria[:except_kind_id]).
      named_like(@criteria[:name]).
      by_id(@criteria[:id]).
      by_relation_name(@criteria[:relation_name]).
      invalid(@criteria[:invalid]).
      isolated(@criteria[:isolated])

    @scope = case @criteria[:sort][:column]
      when 'default' then @scope.alphabetically
      when 'random' then @scope.order('rand()')
      else
        @scope.order(
          @criteria[:sort][:column] => @criteria[:sort][:direction]
        )
    end

    if id = @criteria[:user_group_id]
      ids = UserGroup.where(id: id).to_a.select{|g| g.owner == @user}.map{|g| g.id}
      @scope = @scope.within_user_groups(ids) if ids.present?
    end

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