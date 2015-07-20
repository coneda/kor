class EntitiesController < ApplicationController
  layout 'normal_small', :only => [ :edit, :new, :update, :create, :recent, :invalid ]
  skip_before_filter :verify_authenticity_token

  respond_to :json, :only => [:isolated]
    
  def by_uuid
    @entity = viewable_entities.find_by_uuid(params[:uuid])
    
    if @entity
      redirect_to web_path(:anchor => entity_path(@entity))
    else
      not_found
    end
  end
  
  def other_collection
    @entity = Entity.find(params[:id])
    flash[:error] = I18n.t('errors.other_collection', :id => @entity.id)
    redirect_to denied_path
  end
  
  def metadata
    @entity = viewable_entities.find(params[:id])
    
    if @entity
      send_data Kor::Export::MetaData.new('simple').render(@entity),
        :type => 'text/plain', :filename => "#{@entity.id}.txt"
    else
      flash[:error] = I18n.t('errors.not_found')
      redirect_to back_save
    end
  end

  def gallery
    @query = kor_graph.search(:gallery,
      :page => params[:page]
    )
    
    render :layout => 'wide'
  end
  
  def duplicate
    @entities = Entity.where(:name => params[:name], :kind_id => params[:kind_id])
    
    if params[:render_selection]
      render :template => 'precise', :layout => false
    else
      render :layout => false
    end
  end
  
  def invalid
    if authorized? :delete
      @group = SystemGroup.find_or_create_by_name('invalid')
      @entities = @group.entities.allowed(current_user, :delete).paginate :page => params[:page], :per_page => 30
    else
      redirect_to denied_path
    end
  end
  
  def recent
    if authorized? :edit
      @entities = editable_entities.latest(1.week).searcheable.newest_first.within_collections(params[:collection_id]).paginate(
        :page => params[:page], :per_page => 30
      )
    else
      redirect_to denied_path
    end
  end

  def isolated
    if authorized? :edit
      entities = Entity.allowed(current_user, :view).isolated.newest_first.includes(:kind)
      @result = Kor::SearchResult.new(
        :total => entities.count,
        :page => params[:page],
        :per_page => 16,
        :records => entities.pageit(params[:page], 16)
      )
    else
      render :nothing => true, :status => 403
    end
  end

  def index
    if params[:query] && @entity = viewable_entities.find_by_uuid(params[:query][:name])
      redirect_to web_path(:anchor => entity_path(@entity))
    else
      @query = kor_graph.search(:attribute,
        :criteria => params[:query],
        :page => params[:page]
      )

      render :layout => 'small_normal_bare'
    end
  end

  def show
    @entity = Entity.includes(
      :medium, :kind, :collection, :datings, :creator, :updater, 
      :authority_groups => :authority_group_category
    ).find(params[:id])

    if allowed_to?(:view, @entity.collection)
      respond_to do |format|
        format.json
        format.rdf
      end
    else
      respond_to do |format|
        format.json { render :json => {}, :status => 403 }
        format.rdf { render :nothing => true, :status => 403 }
      end
    end
  end

  def new
    if authorized? :create, Collection.all, :required => :any
      @entity = Entity.new(:collection_id => current_user.default_collection_id)
      kind = Kind.find(params[:kind_id])
      @entity.kind = kind
      @entity.no_name_statement = 'enter_name'
      @entity.medium = Medium.new if @entity.kind_id == Kind.medium_kind.id
    else
      redirect_to denied_path
    end
  end
  
  def multi_upload
    render :layout => "blaze"
  end

  def edit
    @entity = Entity.find(params[:id])
    
    if authorized? :edit, @entity.collection
      render :action => 'edit'  
    else
      redirect_to denied_path
    end
  end

  def create
    @entity = Entity.new
    @entity.kind_id = params[:entity][:kind_id]
    @entity.assign_attributes entity_params
    
    if authorized?(:create, @entity.collection)
      @entity.creator_id = current_user.id
      
      if @entity.save
        if params[:user_group_name]
          transit = UserGroup.owned_by(current_user).find_or_create_by_name(params[:user_group_name])
          transit.add_entities @entity if transit
        end
        
        if !params[:relation_name].blank? && current_entity
          Relationship.relate_and_save(@entity, params[:relation_name], current_entity)
        end
        
        respond_to do |format|
          format.html do
            flash[:notice] = I18n.t('objects.create_success', :o => @entity.display_name)
            redirect_to web_path(:anchor => entity_path(@entity))
          end
          format.json {render :json => {:success => true}}
        end
      else
        respond_to do |format|
          format.json do
            if @entity.medium && @entity.medium.errors[:datahash].present?
              if params[:user_group_name]
                transit = UserGroup.owned_by(current_user).find_or_create_by_name(params[:user_group_name])

                if transit
                  @entity = Medium.where(:datahash => @entity.medium.datahash).first.entity
                  transit.add_entities @entity

                  render :json => {:success => true}
                  return
                end
              end
            end

            render :json => {:success => false, :errors => @entity.errors}, :status => 400
          end
          format.html {render :action => "new", :status => :not_acceptable}
        end
      end
    else
      redirect_to denied_path
    end
  end

  def update
    params[:entity] ||= {}
    params[:entity][:dataset] ||= {}
    params[:entity][:properties] ||= []
    params[:entity][:synonyms] ||= []
    params[:entity][:existing_datings_attributes] ||= {}

    @entity = Entity.find(params[:id])
    
    authorized_to_edit = authorized?(:edit, @entity.collection)
    
    authorized_to_move = if @entity.collection_id == params[:entity][:collection_id].to_i
      true
    else
      authorized?(:delete, @entity.collection) && authorized?(:create, Collection.find(params[:entity][:collection_id]))
    end
    
    if authorized_to_edit && authorized_to_move
      @entity.updater_id = current_user.id

      if @entity.update_attributes(entity_params)
        SystemGroup.find_or_create_by_name('invalid').remove_entities @entity
        flash[:notice] = I18n.t( 'objects.update_success', :o => @entity.display_name )
        redirect_to web_path(:anchor => entity_path(@entity))
      else
        render :action => "edit"
      end
    else
      redirect_to denied_path
    end
  rescue ActiveRecord::StaleObjectError
    flash[:error] = I18n.t('activerecord.errors.messages.stale_entity_update')
    redirect_to :action => 'edit'
  end

  def destroy
    @entity = Entity.find(params[:id])
    if authorized? :delete, @entity.collection
      @entity.destroy
      redirect_to back_save
    else
      redirect_to denied_path
    end
  end

end
