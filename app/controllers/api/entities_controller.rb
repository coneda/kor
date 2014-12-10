class Api::EntitiesController < Api::ApiController

  before_filter :reset_blaze

  def show
    @entity = Entity.
      includes(
        :medium, :kind, :collection, :datings, :creator, :updater, 
        :authority_groups => :authority_group_category
      ).
      find(params[:id])

    if allowed_to?(:view, @entity.collection)
      @entity = Entity.
      where(:collection_id => authorized_collections.map{|c| c.id}).
      includes(:medium, :kind, :collection, :datings, :creator, :updater, :authority_groups => :authority_group_category).
      find(params[:id])
      
      hash = @entity.serializable_hash(
        :include => [:medium, :kind, :collection, :datings, :creator, :updater, :authority_groups],
        :methods => [:synonyms, :dataset, :degree, :properties, :display_name],
        :root => false
      )
      
      hash[:fields] = @entity.kind.field_instances(@entity).map{|f| f.serializable_hash}
      hash[:tags] = @entity.tag_list.join(', ')
      hash[:related] = blaze.relations_for(:include_relationships => true)
      hash[:related_media] = blaze.relations_for(:media => true, :include_relationships => true)
      hash[:links] = WebServices::Dispacher.links_for(@entity)
      hash[:generators] = @entity.kind.generators.map{|g| g.serializable_hash}

      render :json => hash
    else
      redirect_to denied_path(:format => request.format.symbol)
    end
  end
  
  def relationships
    params[:page] ||= 0
    params[:limit] ||= 10

    flash.keep
    render :json => {
      :relationships => blaze.relationships_for(
        :name => params[:name],
        :media => params[:media],
        :offset => params[:page].to_i * params[:limit].to_i,
        :limit => params[:limit].to_i
      )
    }
  end
  
  protected

    def current_entity
      @entity ||= Entity.find(params[:id])
    end

    def blaze
      @blaze ||= Kor::Blaze.new(current_user)
    end

    def reset_blaze
      @blaze = nil
    end

    def authorized?
      true
    end

    def allowed_to?(policy = :view, collections = Collection.all, options = {})
      options.reverse_merge!(:required => :any)
      ::Auth::Authorization.authorized? current_user, policy, collections, options
    end
  
end
