class Kor::Blaze

  def initialize(user)
    @user = user
  end

  def collection_ids
    @collection_ids ||= ::Kor::Auth.authorized_collections(@user).map{|c| c.id}
  end

  def relationship_scope(entity, options = {})
    options.reverse_merge!(
      :relation_names => nil
    )

    result = Relationship.
      select("rs.*, 
        IF(rs.from_id = #{entity.id}, rs.to_id, rs.from_id) other_id,
        IF(rs.from_id = #{entity.id}, tos.name, froms.name) other_name,
        IF(rs.from_id = #{entity.id}, r.name, r.reverse_name) relation_name
      ").
      from('relationships rs').
      joins('LEFT JOIN relations r ON r.id = rs.relation_id').
      joins('LEFT JOIN entities tos on rs.to_id = tos.id').
      joins('LEFT JOIN entities froms on rs.from_id = froms.id').
      where('rs.from_id = :id or rs.to_id = :id', :id => entity.id).
      where("IF(rs.from_id = #{entity.id}, (tos.collection_id IN (:ids)), (froms.collection_id IN (:ids)))", :ids => collection_ids).
      order("relation_name, other_name, created_at")

    if options[:relation_names]
      result = result.where("
        IF(
          rs.from_id = #{entity.id},
          (r.name IN (:names)),
          (r.reverse_name IN (:names))
        )", :names => options[:relation_names]
      )
    end

    result
  end

  def related_entities(entity, options = {})
    options.reverse_merge!(
      :only_media => false,
      :without_media => false,
      :relation_names => nil,
      :kind_ids => nil
    )

    normal_conditions = []
    reverse_conditions = []
    binds = {}

    if options[:only_media]
      normal_conditions << " AND (tos.kind_id = #{Kind.medium_kind.id})"
      reverse_conditions << " AND (froms.kind_id = #{Kind.medium_kind.id})"
    end

    if options[:without_media]
      normal_conditions << " AND (tos.kind_id != #{Kind.medium_kind.id})"
      reverse_conditions << " AND (froms.kind_id != #{Kind.medium_kind.id})"
    end

    if options[:relation_names]
      normal_conditions << " AND (r.name IN (:relation_names))"
      reverse_conditions << " AND (r.reverse_name IN (:relation_names))"
      binds[:relation_names] = options[:relation_names]
    end

    if options[:kind_ids]
      normal_conditions << " AND (tos.kind_id IN (:kind_ids))"
      reverse_conditions << " AND (froms.kind_id IN (:kind_ids))"
      binds[:kind_ids] = options[:kind_ids]
    end

    scope = Entity.find_by_sql([
      "
        (
          SELECT tos.*
          FROM relationships rs
          LEFT JOIN relations r ON r.id = rs.relation_id
          LEFT JOIN entities tos ON rs.to_id = tos.id
          WHERE (rs.from_id = #{entity.id}) #{normal_conditions.join ' '}
        )
        UNION DISTINCT
        (
          SELECT froms.*
          FROM relationships rs
          LEFT JOIN relations r ON r.id = rs.relation_id
          LEFT JOIN entities froms ON rs.from_id = froms.id
          WHERE (rs.to_id = #{entity.id}) #{reverse_conditions.join ' '}
        )
      ", 
      binds
    ])
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
        :methods => [:display_name]
      )
      r[:total_media] = media_count_for(e)
    end

    results
  end
  
  def media_count_for(entity)
    relationship_scope(entity).
      where("IF(rs.from_id = #{entity.id}, tos.medium_id IS NOT NULL, froms.medium_id IS NOT NULL)").
      count(:all)
  end

  def gaga
    
  end
  
end
