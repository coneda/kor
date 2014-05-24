class Kor::Graph::Memory

  def initialize(entity_ids = [])
    @entity_ids = entity_ids
    @nodes = {}
    @entities = {}
    
    preload_entities
  end
  
  def preload_entities
    unless @entity_ids.empty?
      add_ids @entity_ids
    
      2.times do
        add_triples Investigator.new.triples(@entity_ids)
        @entity_ids = ids
      end
    else
      add_triples Investigator.new.triples(:all)
    end
  end
  
  def add_triples(triples)
    triples.each do |t|
      add_triple(t[0], t[1], t[2], t[3])
    end
  end
  
  def add_triple(from, name, reverse_name, to)
    @nodes[from] ||= {}
    @nodes[to] ||= {}
    
    @nodes[from][name] ||= {}
    @nodes[from][name][to] ||= true
    
    @nodes[to][reverse_name] ||= {}
    @nodes[to][reverse_name][from] ||= true
  end
  
  def retrieve
    Entity.find(@nodes.keys - @entities.keys).each do |entity|
      @entities[entity.id] = entity
    end
  end
  
  def add_entity(entity)
    @entities[entity.id] = entity
  end
  
  def add_ids(ids)
    ids.each{|id| @nodes[id] = {}}
  end
  
  def reload(entity_ids)
    Entity.find(entity_ids).each do |entity|
      @entities[entity.id] = entity
    end
  end
  
  def destroy(entity_ids)
    related(entity_ids).each do |id|
      @nodes[id].each do |rel, es|
        entity_ids.each do |e_id|
          es.delete e_id
        end
      end
    end
    
    entity_ids.each do |id|
      @nodes.delete id
    end
  end
  
  def related(entity_ids)
    entity_ids.map do |id|
      puts id unless @nodes[id]
      @nodes[id].values.map{|v| v.keys}
    end.flatten.uniq
  end
  
  def related_entities(entity_ids)
    related(entity_ids).map{|id| @entities[id]}
  end
  
  def entity(id)
    @entities[id]
  end
  
  def ids
    @nodes.keys
  end
  
end
