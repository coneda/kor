class Investigator
  
  def investigate(entity_ids, chains)
    time = Time.now
    results = {}
  
    chains.each do |chain|
      chain_results = retrieve_by_chain(entity_ids, chain)
      unless chain_results.empty?
        results[chain[:name]] = chain_results
      end
    end
    
    results
  end
  
  def retrieve_by_chain(entity_ids, chain)
    results = entity_ids
  
    chain[:filters].each do |f|
      results = relationships_for(results, f[:relations], f[:kinds]).values.flatten
    end
    
    results
  end
  
  def related_entities_for(entity_ids, relation_names = nil, kind_ids = nil)
    entity_ids = [entity_ids] unless entity_ids.is_a?(Array)
    if relation_names
      relation_names = [relation_names] unless relation_names.is_a?(Array)
    else
      relation_names = []
    end
    kind_ids = case kind_ids
      when Array then kind_ids
      when nil then []
      else
        [kind_ids]
    end
  
    result = relationships_for(entity_ids, relation_names, kind_ids)
    if relation_names.size == 1
      result.values.flatten
    else
      result
    end
  end
  
  def client
    @client ||= ActiveRecord::Base.connection
  end
  
  def triples(entity_ids = :all)
    query_select = "
      SELECT
        rs.from_id as from_id,
        rs.to_id as to_id,
        r.name as name,
        r.reverse_name as reverse_name
    "
    query_from = "
      FROM
        relationships as rs
        LEFT JOIN relations as r ON r.id = rs.relation_id
    "
    
    query_where = ""
    
    if entity_ids == :all
      query_select << ", 1 as direction"
    else
      entity_list = entity_ids.join(',')
      query_select << ", rs.from_id IN (#{entity_list}) as direction"
      query_where << "
        WHERE
          rs.from_id IN (#{entity_list}) OR
          rs.to_id IN (#{entity_list})
      "
    end
    
    client.select_all(query_select + query_from + query_where).map do |row|
      [row['from_id'], row['name'], row['reverse_name'], row['to_id']]
    end
  end
  
  def sub_graph(entity_ids, depth = 2)
    new_graph = Kor::Graph::Memory.new
  
    while depth > 0
      new_graph.add_triples triples(entity_ids)
      entity_ids = new_graph.ids
      depth -= 1
    end
    
    return new_graph
  end
  
  def relationships_for(entity_ids, relation_names = nil, kind_ids = nil)
    if entity_ids.empty?
      {}
    else
      entity_list = entity_ids.join(',')
      parts = {
        :straight => ["rs.from_id IN (#{entity_list})"],
        :reverse => ["rs.to_id IN (#{entity_list})"]
      }
      
      unless relation_names.blank?
        relation_mysql = relation_names.map{|n| "'#{n}'"}.join(',')
        parts[:straight] << "r.name IN (#{relation_mysql})"
        parts[:reverse] << "r.reverse_name IN (#{relation_mysql})"
      end
      
      if kind_ids && !kind_ids.empty?
        kind_ids = kind_ids.map do |id|
          case id
            when String then Kind.find_by_name(id).id
            when Integer then id
            else
              raise "unknown kind #{id.inspect}"
          end
        end
        kind_sql = kind_ids.join(',')
        
        parts[:straight] << "ts.kind_id IN (#{kind_sql})"
        parts[:reverse] << "fs.kind_id IN (#{kind_sql})"
      end
      
      where = "(#{parts[:straight].join(' AND ')}) OR (#{parts[:reverse].join(' AND ')})"
      
      query = "
        SELECT
          rs.from_id IN (#{entity_list}) as direction,
          fs.kind_id as from_kind_id,
          rs.from_id as from_id,
          r.name as relation_name,
          r.reverse_name as reverse_relation_name,
          rs.to_id as to_id, 
          ts.kind_id as to_kind_id
        FROM relationships as rs
          LEFT JOIN entities fs ON fs.id = rs.from_id
          LEFT JOIN entities ts ON ts.id = rs.to_id
          LEFT JOIN relations r ON r.id = rs.relation_id
        WHERE
          #{where}
      "
      
      raw_result = client.select_all(query)
      results = {}
      
      raw_result.each do |row|
        if row['direction'].to_i == 1
          results[row['relation_name']] ||= []
          results[row['relation_name']] << row['to_id'].to_i
        else
          results[row['reverse_relation_name']] ||= []
          results[row['reverse_relation_name']] << row['from_id'].to_i
        end
      end
      
      results
    end
  end
  
end
