class Kor::Graph::Search::Query::Base

  # Constructor

  def initialize(user, options = {})
    @user = user

    @options = options
    @options
    @options[:criteria] = (@options[:criteria] || {}).symbolize_keys
    
    self.params = options[:criteria]
  end
  
  
  # Main
  
  def ids
    items.map{|e| e.id}
  end
  
  def items
    run
  end

  def records
    items
  end
  
  def hashes
    items.map{|e| e.attributes}
  end
  
  def total
    run
    @total
  end
  
  
  # Parameters
  
  def params=(values)
    (values || {}).each do |param, value|
      send "#{param}=", value
    end
  end
  
  def self.define_params(params)
    params.each do |name, default|
      define_method name do
        instance_variable_get("@#{name}") || instance_variable_set("@#{name}", default)
      end
      
      define_method "#{name}=" do |value|
        instance_variable_set("@#{name}", value)
      end
    end
  end
  

  # Accessors
  
  attr_reader :user
  attr_reader :options
  
  def authorized_collection_ids
    ::Kor::Auth.authorized_collections(user).map{|c| c.id}
  end
  
  def per_page
    (options[:per_page] ||= 10).to_i
  end
  
  def page
    (options[:page] ||= 1).to_i
  end
  
  def criteria
    options[:criteria] ||= {}
  end
  
  def self.human_attribute_name(*args)
    Entity.human_attribute_name(args)
  end
  
  def id
    (rand * 10000).round
  end
  
  def new_record?
    true
  end
  
  def method_missing(name, *args)
    value = if name.to_s.match /^[a-z_]+_before_type_cast$/
      name.to_s.split('_')[0..-4].join('_').to_sym
    else
      name
    end
    
    if criteria.keys.include? value
      criteria[value]
    else
      super
    end
  end
  
  
  # Processing
  
  def results
    @results ||= Kor::Graph::Search::Result.new(self)
  end
  
  private
    def run(use_cache = true)
      @results_cache = (use_cache ? @results_cache ||= execute : execute)
    end
    
    def execute
      raise "please implement"
    end

end
