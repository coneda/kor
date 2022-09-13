class Kor::Search
  def initialize(user, criteria = {})
    @user = user
    @criteria = criteria.reverse_merge(
      page: 1,
      per_page: 10,
      sort: {column: 'name', direction: 'ASC'}
    )
    sanitize!
    validate!
    run
  end

  def run
    if engine == 'elastic'
      elastic
    else
      active_record
    end
  end

  def active_record
    @scope = Entity.
      allowed(@user, @criteria[:policy] || :view).
      within_collections(@criteria[:collection_id]).
      within_authority_groups(@criteria[:authority_group_id]).
      only_kinds(@criteria[:kind_id]).
      except_kinds(@criteria[:except_kind_id]).
      named_like(@criteria[:name]).
      by_id(@criteria[:id]).
      by_uuid(@criteria[:uuid]).
      by_relation_name(@criteria[:relation_name]).
      invalid(@criteria[:invalid]).
      isolated(@criteria[:isolated]).
      tagged_with(@criteria[:tags]).
      dated_in(@criteria[:dating]).
      created_after(@criteria[:created_after]).
      created_before(@criteria[:created_before]).
      updated_after(@criteria[:updated_after]).
      updated_before(@criteria[:updated_before]).
      updated_by(@criteria[:updated_by]).
      created_by(@criteria[:created_by]).
      by_file_size(@criteria[:file_size]).
      by_file_size(@criteria[:larger_than], :larger).
      by_file_size(@criteria[:smaller_than], :smaller).
      by_file_type(@criteria[:file_type]).
      by_file_name(@criteria[:file_name]).
      by_datahash(@criteria[:datahash])

    @scope = case @criteria[:sort][:column]
    when 'default' then @scope.order('name')
    when 'random' then @scope.order(Arel.sql('rand()'))
    else
      @scope.order(
        @criteria[:sort][:column] => @criteria[:sort][:direction]
      )
    end

    if id = @criteria[:user_group_id]
      ids = UserGroup.where(id: id).to_a.
        select{ |g| g.owner == @user || g.shared? }.
        map{ |g| g.id }
      @scope = @scope.within_user_groups(ids) if ids.present?
    end

    if @criteria[:no_media]
      @scope = @scope.without_media
    end
  end

  def elastic
    @search_result = if Kor::Elastic.available?
      Kor::Elastic.new(@user).search(@criteria)
    else
      raise Kor::Exception, 'elasticsearch is not available'
    end
  end

  def records
    if engine == 'elastic'
      @search_result.records
    else
      @scope.pageit(@criteria[:page], @criteria[:per_page])
    end
  end

  def total
    if engine == 'elastic'
      @search_result.total
    else
      @scope.count
    end
  end

  def keys
    @criteria.keys
  end

  def compat_keys
    return [
      :name, :id, :uuid, :collection_id, :kind_id, :except_kind_id, :dating,
      :created_after, :tags, :relation_name, :sort, :page, :per_page,
      :created_before, :updated_before, :updated_after, :engine, :updated_by,
      :created_by, :file_size, :file_type, :file_name, :datahash, :larger_than,
      :smaller_than
    ]
  end

  def elastic_keys
    [:terms, :property, :dataset, :related, :degree, :max_degree, :min_degree]
  end

  def active_record_keys
    [:isolated, :invalid, :user_group_id, :authority_group_id]
  end

  def surplus_keys
    keys - compat_keys - elastic_keys - active_record_keys
  end

  def sanitize!
    # scan for odd number of quotes
    elastic_keys.each do |k|
      v = @criteria[k]
      if v.is_a?(String) && v.scan(/"/).size.odd?
        @criteria[k] = v.gsub('"', '')
      end
    end
  end

  def validate!
    unless ['active_record', 'elastic'].include?(engine)
      raise Kor::Exception, "#{engine.inspect} is not a valid search engine"
    end

    if surplus_keys.size > 0
      raise Kor::Exception, "#{surplus_keys.inspect} are not known search keys"
    end

    if engine == 'active_record'
      elastic_keys.each do |k|
        if @criteria[k].present?
          raise Kor::Exception, "#{k} is only supported with elasticsearch"
        end
      end
    end

    if engine == 'elastic'
      active_record_keys.each do |k|
        if @criteria[k].present?
          raise Kor::Exception, "#{k} is only supported with active_record"
        end
      end

      unless Kor::Elastic.available?
        elastic_keys.each do |k|
          next if @criteria[k].blank?

          msg = "#{k} is only supported with elasticsearch"
          msg << 'but elasticsearch is unavailable'
          raise Kor::Exception, msg
        end

        raise Kor::Exception, "elasticsearch requested but unavailable"
      end
    end
  end

  def requested_engine
    @criteria[:engine]
  end

  def requires_active_record?
    active_record_keys.each do |k|
      if @criteria[k].present?
        return 'active_record'
      end
    end

    false
  end

  # use elastic if available and enabled
  def engine
    return requested_engine if requested_engine.present?
    return 'active_record' if requires_active_record?

    Kor::Elastic.available? ? 'elastic' : 'active_record'
  end
end
