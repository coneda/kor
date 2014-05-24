class Kor::Graph::Search::Result

  # Constructor
  
  def initialize(query, attributes = {})
    @query = query
    
    attributes.each do |k, v|
      instance_variable_set "@#{k}", v
    end
  end
  
  def self.from(object)
    case object
      when WillPaginate::Collection, ActiveRecord::Relation
        new(nil,
          :items => object,
          :ids => object.map{|o| o.id},
          :hashes => object.map{|o| o.attributes},
          :total => object.total_entries,
          :per_page => object.per_page,
          :page => object.current_page
        )
      else
        raise "impossible to construct results from #{object.inspect}"
    end
  end
  
  # Main
  
  def ids
    @ids ||= query.ids
  end
  
  def items
    @items ||= query.items
  end
  
  def hashes
    @hashes ||= query.hashes
  end
  
  def total
    @total ||= query.total
  end
  
  
  # Accessors
  
  attr_reader :query
  
  def per_page
    @per_page ||= query.per_page
  end
  
  def page
    @page ||= query.page
  end
  
  def total_pages
    (total - 1) / per_page + 1
  end
  
  def needs_pagination?
    total_pages > 1
  end
  
  def first_page?
    page == 1
  end
  
  def last_page?
    page == total_pages
  end
  
  def empty?
    total == 0
  end
  
end
