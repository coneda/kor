class Kor::Blaze

  def initialize(user)
    @user = user
  end

  def collection_ids
    @collection_ids ||= ::Auth::Authorization.authorized_collections(@user).map{|c| c.id}
  end

  def relationship_scope(entity)
    Relationship.
      select("rs.*, 
        IF(rs.from_id = #{entity.id}, rs.to_id, rs.from_id) other_id,
        IF(rs.from_id = #{entity.id}, tos.name, froms.name) other_name,
        IF(rs.from_id = #{entity.id}, r.name, r.reverse_name) relation_name
      ").
      from('relationships rs').
      joins('LEFT JOIN relations r ON r.id = rs.relation_id').
      joins('LEFT JOIN entities tos on rs.to_id = tos.id').
      joins('LEFT JOIN entities froms on rs.from_id = froms.id').
      where('rs.from_id = ? or rs.to_id = ?', entity.id, entity.id).
      where("IF(rs.from_id = #{entity.id}, (tos.collection_id IN (?)), (froms.collection_id IN (?)))", collection_ids, collection_ids).
      order("relation_name, other_name, created_at")
  end

  def relations_for(entity, options = {})
    options.reverse_merge!(
      :media => false
    )

    base = relationship_scope(entity).
      select("
        rs.*, 
        r.name name, 
        r.reverse_name reverse_name,
        COUNT(rs.id) amount
      ").
      group("r.name, r.reverse_name, rs.from_id = #{entity.id}")

    if options[:media]
      base = base.where("IF(rs.from_id = #{entity.id}, tos.medium_id IS NOT NULL, froms.medium_id IS NOT NULL)")
    else
      base = base.where("IF(rs.from_id = #{entity.id}, tos.medium_id IS NULL, froms.medium_id IS NULL)")
    end

    results = base.map do |r|
      {
        :name => (r.from_id == entity.id ? r.name : r.reverse_name),
        :amount => r.amount
      }
    end.sort do |x, y|
      x[:name] <=> y[:name]
    end

    # Eleminate symmetric relationships
    reduced_results = []
    results.each do |result|
      existing = reduced_results.find do |r| 
        r[:name] == result[:name]
      end

      if existing
        existing[:amount] += result[:amount]
      else
        reduced_results << result
      end
    end

    if options[:include_relationships]
      reduced_results.each do |r|
        r[:page] = 1
        r[:relationships] = relationships_for(
          entity,
          :name => r[:name], 
          :media => options[:media]
        )
      end
    end

    reduced_results
  end

  def relationships_for(entity, options = {})
    options.reverse_merge!(
      :name => nil,
      :offset => 0,
      :limit => 10,
      :media => false
    )

    base = relationship_scope(entity).
      limit(options[:limit]).
      offset(options[:offset])

    if options[:name]
      base = base.where("IF(rs.from_id = #{entity.id}, r.name, r.reverse_name) = ?", options[:name])
    end

    if options[:media]
      base = base.where("IF(rs.from_id = #{entity.id}, tos.medium_id, froms.medium_id) IS NOT NULL")
    else
      base = base.where("IF(rs.from_id = #{entity.id}, tos.medium_id, froms.medium_id) IS NULL")
    end

    lookup = []

    results = base.map do |r|
      lookup << r.other_id

      {
        :properties => r.properties, 
        :entity => nil,
        :entity_id => r.other_id,
        :id => r.id,
        :page => options[:offset] / options[:limit] + 1
      }
    end

    entities = {}

    Entity.includes(:kind, :medium).where("id IN (?)", lookup).all.each do |e|
      entities[e.id] = e
    end

    results.each do |r|
      e = entities[r[:entity_id]]

      r[:entity] = e.serializable_hash(
        :root => false, 
        :include => [:kind, :medium], 
        :except => [:attachment],
        :methods => [:display_name]
      )
      r[:total_media] = media_count_for(e)
    end

    results
  end
  
  def media_count_for(entity)
    relationship_scope(entity).
      where("IF(rs.from_id = #{entity.id}, tos.medium_id IS NOT NULL, froms.medium_id IS NOT NULL)").
      count
  end

  def gaga
    
  end
  
end
