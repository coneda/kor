class Api::EntitiesController < Api::ApiController

  before_filter :reset_blaze

  def show
    @entity = Entity.
      where(:collection_id => authorized_collections.map{|c| c.id}).
      includes(:medium, :kind, :collection, :datings).
      find(params[:id])
      
    out = @entity.serializable_hash(:include => [:medium, :kind, :collection, :datings])
    primaries = @entity.related(:assume => :media, :search => :primary)
    out['primary'] = primaries.map do |e|
      e.name + "<br />(#{e.uuid})<br />" + e.datings.map do |d|
        "#{d.label}: #{d.dating_string}"
      end.join('<br />')
    end.join(', ')
    out['secondary'] = primaries.map do |pr| 
      pr.related(:assume => :primary, :search => :secondary).map do |e|
        e.name + "<br />(#{e.uuid})<br />" + e.datings.map do |d|
          "#{d.label}: #{d.dating_string}"
        end.join('<br />')
      end
    end.flatten.join(', ')
    out['rating_id'] = params[:rating_id]
      
    flash.keep
    render :json => out.as_json
  end
  
  def show_full
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
    hash[:generators] = @entity.kind.generators.only_attributes.map do |generator|
      generator.to_html(@entity)
    end.select{|h| !h.blank?}

    # TODO: generators (?), auth (tagging)
    
    flash.keep
    render :json => hash
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
  
  # def deep_media
  #   @entity = Entity.find(params[:id])
  #   params[:page] ||= 0
    
  #   flash.keep
  #   render :json => Kor::Blaze.relationships_for(current_user, @entity,
  #     :media => true,
  #     :offset => params[:page].to_i * 12,
  #     :limit => 12
  #   )
  # end
  
  protected

    def current_entity
      @entity ||= Entity.find(params[:id])
    end

    def blaze
      @blaze ||= Kor::Blaze.new(current_user, current_entity)
    end

    def reset_blaze
      @blaze = nil
    end

    def authorized?
      true
    end
  
end
