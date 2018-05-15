class Kor::Graph
  
  def initialize(options = {})
    unless options[:user].is_a?(User)
      raise Kor::Exception, "#{options[:user].inspect} is no instance of User" 
    end

    @options = options
  end

  def search(criteria = {})
    @criteria = criteria
    sanitize_criteria

    if criteria[:elastic]
      by_elastic
    else
      by_active_record
    end
  end

  def by_elastic
    unavailable = [:relation_name]
    if (@criteria.keys & []).size > 0
      raise "searching by any #{unavailable.inspect} is only available without elasticsearch"
    end

    collection_ids = 
      @criteria[:collection_id] || 

    results = elastic.search(
      page: @criteria[:page],
      per_page: @criteria[:per_page],
      term: @criteria[:term],
      name: @criteria[:name],
      subtype: @criteria[:subtype],
      property: @criteria[:property],
      dataset: @criteria[:dataset],
      collection_id: collection_id,
      kind_id: @criteria[:kind_id],
      tag: @criteria[:tag],
      related_to: related_to,
      synonym: @criteria[:synonym],
      id: @criteria[:id],
      uuid: @criteria[:uuid],
      comment: @criteria[:comment]
    )
  end

  def by_active_record
    unavailable = [:term, :property, :dataset, :synonym]
    if (@criteria.keys & unavailable).size > 0
      raise Kor::Exception, "searching by any of #{unavailable.inspect} is only available with elasticsearch"
    end

    results = Entity.
      without_media.
      alphabetically.
      within_collections(collection_id).
      only_kinds(@criteria[:kind_id]).
      by_subtype(@criteria[:subtype]).
      named_like(@criteria[:name]).
      dated_in(@criteria[:dating]).
      tagged_with(@criteria[:tag]).
      related_to(user, @criteria[:related_to]).
      by_id(@criteria[:id]).
      by_uuid(@criteria[:uuid]).
      by_comment(@criteria[:comment])

    Kor::SearchResult.new(
      total: results.count('entities.id'),
      records: results.pageit(@criteria[:page], @criteria[:per_page]).to_a
    )
  end

  
  protected

    def sanitize_criteria
      arrays = [
        :kind_id, :collection_id, :tag, :dating, :related_via, :related_to,
        :subtype, :name, :property, :related_to, :dating, :synonym, :id
      ]

      arrays.each do |k|
        @criteria[k] = to_array(@criteria[k])
      end

      @criteria.delete_if{|k, v| v.nil?}
    end

    def collection_id
      results = Kor::Auth.authorized_collections(user, @criteria[:policy]).pluck(:id)
      if @criteria[:collection_id]
        results &= @criteria[:collection_id]
      end
      results
    end

    def related_to
      if @criteria[:related_to]
        ids = Kor::Auth.authorized_collections(user, @criteria[:policy]).pluck(:id)
        @criteria[:related_to].map do |rt|
          rt.merge('entity_collection_id' => ids)
        end
      end
    end

    def to_array(value)
      return nil if value.nil?
      value.is_a?(Array) ? value : [value]
    end
  
    def user
      @options[:user]
    end

    def elastic
      @elastic ||= Kor::Elastic.new
    end

end
