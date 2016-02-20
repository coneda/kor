class Kor::Graph::Search::Query::Attribute < Kor::Graph::Search::Query::Base
  
  # Constructor
  
  def initialize(user, options = {})
    options.reverse_merge!(:media => false)
    
    super user, options
  end
  
  
  # Parameters
  
  define_params(
    :identifier => nil,
    :relationships => [],
    :kind_id => nil,
    :name => nil,
    :dating_string => nil,
    :collection_ids => 'all',
    :properties => nil,
    :dataset => {},
    :tag_list => ""
  )
  
  def collection_ids
    case @collection_ids
      when Array then @collection_ids
      when String then Collection.where(:id => @collection_ids.split(',').map{|i| i.to_i}).map{|c| c.id}
      else
        ::Kor::Auth.authorized_collections(user, :view).map{|c| c.id}
    end
  end
  
  def personal_collection_ids
    Collection.personal.map{|c| c.id}
  end
  
  
  # Processing

  private

    def execute
      if criteria[:identifier]
        scope = Entity.allowed(user, :view).
          is_ia(criteria[:kind_id]).
          within_collections(collection_ids).
          where("id = ? OR uuid = ?", criteria[:identifier], criteria[:identifier]).
          first
      else
        tmp_result = Entity.allowed(user, :view).
          is_a(criteria[:kind_id]).
          named_like(user, criteria[:name]).
          has_property(user, criteria[:properties]).
          dated_in(criteria[:dating_string]).
          dataset_attributes(user, criteria[:dataset]).
          related_to(user, criteria[:relationships]).
          within_collections(collection_ids).
          includes(:medium)
          
        unless tag_list.empty?
          tmp_result = tmp_result.tagged_with(tag_list.split(/,\s*/))
        end
        
        tmp_result = tmp_result.searcheable unless options[:media]
        
        @total = tmp_result.count("entities.id")
        
        tmp_result.alphabetically.paginate(page: page, per_page: 10)
      end
    end
  
end
