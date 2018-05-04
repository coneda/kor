class EntitiesController < JsonController

  layout 'normal_small', :only => [ :edit, :new, :update, :create, :recent, :invalid ]
  skip_before_filter :verify_authenticity_token

  respond_to :json, only: [:isolated]

  def metadata
    @entity = viewable_entities.find(params[:id])
    
    if @entity
      send_data(Kor::Export::MetaData.new(current_user).render(@entity),
        type: 'text/plain',
        filename: "#{@entity.id}.txt"
      )
    else
      flash[:error] = I18n.t('errors.not_found')
      redirect_to back_save
    end
  end

  def gallery
    params[:include] = param_to_array(params[:include], ids: false)

    entities = viewable_entities.
      includes(:kind, :collection, :medium, :tags).
      media.
      newest_first

    @total = entities.count
    @per_page = 16
    @records = entities.pageit(params[:page], 16)
  end
  
  def invalid
    if authorized? :delete
      @per_page = 30
      group = SystemGroup.find_or_create_by(name: 'invalid')
      scope = group.entities.allowed(current_user, :delete)
      @total = scope.count
      @records = scope.pageit(@page, @per_page)

      render action: 'index'
    else
      render_403
    end
  end
  
  def recent
    params[:include] = param_to_array(params[:include], ids: false)

    if authorized? :edit
      @per_page = 30
      scope = Entity.
        includes(:creator, :updater, :collection, :kind, :tags).
        allowed(current_user, :edit).
        without_media.
        newest_first.
        within_collections(params[:collection_id])
      @total = scope.count
      @records = scope.pageit(@page, @per_page)

      render action: 'index'
    else
      render_403
    end
  end

  def isolated
    params[:include] = param_to_array(params[:include], ids: false)

    if authorized? :edit
      @per_page = 16
      scope = Entity.
        allowed(current_user, :view).
        isolated.
        newest_first.
        includes(:kind, :collection, :tags, :medium)

      @total = scope.count
      @records = scope.pageit(@page, @per_page)

      render action: 'index'
    else
      render_403
    end
  end

  def recently_created
    scope = Entity.
      allowed(current_user, :view).
      by_relation_name(params[:relation_name]).
      newest_first.includes(:kind)

    @total = scope.count
    @records = scope.pageit(@page, @per_page)

    render action: 'index'
  end

  def recently_visited
    history_entity_ids = current_user.history.map do |url|
      if m = url.match(/\/blaze\#\/entities\/(\d+)$/)
        m[1].to_i
      else
        nil
      end
    end

    scope = Entity.
      allowed(current_user, :view).
      by_ordered_id_array(history_entity_ids.reverse).
      by_relation_name(params[:relation_name]).
      includes(:kind).
      newest_first

    @total = scope.count
    @results = scope.pageit(@page, @per_page)

    render action: 'index'
  end

  def random
    params[:include] = param_to_array(params[:include], ids: false)

    scope = Entity.allowed(current_user, :view).media
    @total = scope.count

    amount = 4
    @records = if @total < amount
      scope.to_a
    else
      o = 0
      Array.new(amount).map do |i|
        o += [(rand(@total) / amount).round, 1].max
        scope.limit(1).offset(o).to_a.first
      end
    end

    render action: 'index'
  end

  def index
    params[:include] = param_to_array(params[:include], ids: false)
    params[:ids] = param_to_array(params[:ids])
    params[:kind_id] = param_to_array(params[:kind_id])
    params[:related_per_page] = [
      (params[:related_per_page] || 1).to_i,
      Kor.settings['max_included_results_per_result']
    ].min
    params[:related_relation_name] = param_to_array(params[:related_relation_name], ids: false)
    params[:related_kind_id] = param_to_array(params[:related_kind_id])

    respond_to do |format|
      format.json do
        @results = kor_graph.search(:attribute,
          criteria: {
            entity_id: params[:ids],
            name: params[:terms],
            relation_name: params[:relation_name],
            kind_id: params[:kind_id]
          },
          media: params[:include_media],
          per_page: params[:per_page],
          page: params[:page]
        )
      end
      format.html do
        if params[:query] && @entity = viewable_entities.find_by(:uuid => params[:query][:name])
          redirect_to web_path(:anchor => entity_path(@entity))
        else
          @query = kor_graph.search(:attribute,
            criteria: params[:query],
            page: params[:page]
          )
          render :layout => 'small_normal_bare'
        end
      end
    end
  end

  def show
    params[:include] = param_to_array(params[:include], ids: false)
    params[:related_per_page] = [
      (params[:related_per_page] || 10).to_i,
      Kor.settings['max_results_per_request']
    ].min
    params[:related_relation_name] = param_to_array(params[:related_relation_name], ids: false)
    params[:related_kind_id] = param_to_array(params[:related_kind_id])

    scope = Entity.includes(
      :medium, :kind, :collection, :datings, :creator, :updater, 
      authority_groups: :authority_group_category
    )
    id = (params[:id] || '').strip.presence
    if id.size == 36
      @entity = scope.find_by!(uuid: params[:id])
    else
      @entity = scope.find_by!(id: params[:id])
    end

    respond_to do |format|
      if allowed_to?(:view, @entity.collection)
        format.json
      else
        format.json { render nothing: true, status: 403 }
      end
    end
  end

  def relation_counts
    @relations = Entity.find(params[:id]).relation_counts(current_user)
    format.json {render json: @relations}
  end

  def new
    if authorized? :create, Collection.all, :required => :any
      @entity = Entity.new(:collection_id => current_user.default_collection_id)
      kind = Kind.find(params[:kind_id])
      @entity.kind = kind
      @entity.no_name_statement = 'enter_name'
      @entity.medium = Medium.new if @entity.kind_id == Kind.medium_kind.id
    else
      render_403
    end
  end
  
  def multi_upload
    render :layout => "blaze"
  end

  def edit
    @entity = Entity.find(params[:id])
    # @entity.datings.build label: @entity.kind.dating_label

    if authorized? :edit, @entity.collection
      render :action => 'edit'  
    else
      render_403
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
          transit = UserGroup.owned_by(current_user).find_or_create_by(name: params[:user_group_name])
          transit.add_entities @entity if transit
        end

        if params[:target_entity_id].present? && params[:relation_name]
          relationship = Relationship.relate(@entity, params[:relation_name], params[:target_entity_id])
          if authorized_for_relationship?(relationship, :create)
            relationship.save!
          end
        end
        
        @record = @entity
        render_200 I18n.t('objects.create_success', o: @entity.display_name)
      else
        if @entity.medium && @entity.medium.errors[:datahash].present?
          if params[:user_group_name]
            transit = UserGroup.owned_by(current_user).find_or_create_by(name: params[:user_group_name])

            if transit
              @entity = Medium.where(datahash: @entity.medium.datahash).first.entity
              transit.add_entities @entity

              # TODO: make sure this is tested
              render_200 I18n.t('objects.create_success', o: @entity.display_name, ug: transit.name)
            end
          end
        else
          render_406 build_nested_errors(@entity)
        end
      end
    else
      render_403
    end
  end

  # def render_406(errors, message = nil)
  #   @errors = errors
  #   @message = message || I18n.t('activemodel.errors.template.header')
  #   render template: 'layouts/message', status: 406
  # end

  def update
    params[:entity][:existing_datings_attributes] ||= []

    @entity = Entity.find(params[:id])

    authorized_to_edit = authorized?(:edit, @entity.collection)
    
    authorized_to_move = if @entity.collection_id == params[:entity][:collection_id].to_i
      true
    else
      authorized?(:delete, @entity.collection) && 
      authorized?(:create, Collection.find(params[:entity][:collection_id]))
    end

    if authorized_to_edit && authorized_to_move
      @entity.updater_id = current_user.id

      if @entity.update_attributes(entity_params)
        SystemGroup.find_or_create_by(:name => 'invalid').remove_entities @entity
        render_200 I18n.t('objects.update_success', o: @entity.display_name)
      else
        render_406 build_nested_errors(@entity)
      end
    else
      render_403
    end
  rescue ActiveRecord::StaleObjectError
    flash[:error] = I18n.t('activerecord.errors.messages.stale_entity_update')
    render action: 'edit'
  end

  def update_tags
    new_tags = params[:entity].permit(:tags)['tags'].presence || ""
    new_tags = new_tags.split(/,\s*/)
    @entity = Entity.find(params[:id])
    
    if authorized? :tagging, @entity.collection
      @entity.tag_list += new_tags
      
      if @entity.save
        render_200 I18n.t('objects.update_success',
          o: I18n.t('activerecord.models.tag', count: 'other')
        )
      else
        @errors = @entity.errors
        render_406
      end
    else
      render_403
    end
  end

  def destroy
    @entity = Entity.find(params[:id])
    if authorized? :delete, @entity.collection
      @entity.destroy
      redirect_to back_save
    else
      render_403
    end
  end

  protected

    def entity_params
      params.require(:entity).permit(
        :lock_version,
        :kind_id,
        :collection_id,
        :name, :distinct_name, :subtype, :comment, :no_name_statement,
        :tag_list,
        :synonyms => [],
        :datings_attributes => [
          :id, :_destroy, :label, :dating_string, :lock_version
        ],
        :dataset => params[:entity][:dataset].permit!,
        :properties => [:label, :value],
        :medium_attributes => [:id, :image, :document]
      ).tap do |e|
        e[:properties] ||= []
        e[:synonyms] ||= []
      end
    end

    def build_nested_errors(entity)
      entity.errors.as_json.reject{|k, v| k.match(/^datings/)}.merge(
        'datings' => entity.datings.map{|d| d.errors.as_json}
      )
    end

end
