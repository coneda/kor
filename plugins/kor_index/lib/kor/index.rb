class SampleAnalyzer < Ferret::Analysis::Analyzer
  include Ferret::Analysis
  
  def token_stream(field, str)
    LowerCaseFilter.new(StandardTokenizer.new str)
  end
end

class Kor::Index

  def initialize
    @logger = Logger.new("log/ferret.simple_search.#{Rails.env}.log")
  end
  
  def path
    if Rails.env != 'production'
      "#{Rails.root}/data/ferret.#{Rails.env}"
    else
      "#{Rails.root}/data/ferret"
    end
  end
  
  def index(reload = false)
    if reload || @index.nil?
      @index = Ferret::Index::Index.new(:path => path, :analyzer => SampleAnalyzer.new)
      add_field(:untokenized_name, :store => :yes, :index => :untokenized, :term_vector => :no)
    end
    
    @index
  end
  
  def add_field(name, options = {})
    @index.field_infos.add_field(name, options) unless @index.field_infos.fields.include?(name)
  end
  
  def flush
    index.flush
  end
  
  def rebuild
    drop
    
    Entity.alphabetically.find_each do |entity|
      puts rand
      create(entity, true, :related => false)
    end

    flush
  end
  
  def drop
    system "rm -rf #{path}"
    index(true)
  end

  def create(entity, options = {})
    options.reverse_merge!(:flush => false)
  
    index << {
      :id => entity.id,
      :name => entity.name,
      :untokenized_name => entity.name,
      :synonyms => entity.synonyms,
      :distinct_name => entity.distinct_name,
      :properties => entity.properties,
      :dataset => entity.dataset
    }
    
    flush if options[:flush]
  end
  
  def update(entity, options = {})
    options.reverse_merge!(:flush => false)
    destroy(entity, :flush => false)
    create(entity, :flush => options[:flush])
  end
  
  def destroy(entity, options = {})
    options.reverse_merge!(:flush => false)
  
    hit = index.search("id:#{entity.id}").hits.first
    if hit
      index.delete(hit.doc)
      flush if options[:flush]
    end
  end
  
  def query_params(params)
    return {
      :query => (params[:terms].blank? ? "*" : params[:terms].split.map{|p| "*#{p}*"}.join(" ")),
      :options => {}
    }
  end
  
  def synchronize
    index.synchronize do
      yield
    end
  end
  
  def search(user, params, page = 0, page_size = 10)
    query = query_params(user, params)
    index.search(query[:query], query[:options].merge(:offset => page * page_size, :limit => page_size))
  end
  
  def related_entities_for(entity, relations = nil, kinds = nil)
    investigator.related_entities_for entity, relations, kinds
  end
  
  def investigator
    @investigator ||= Investigator.new
  end
  
end
