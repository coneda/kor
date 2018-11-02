class EntitiesController < JsonController

  # layout 'normal_small', :only => [ :edit, :new, :update, :create, :recent, :invalid ]
  # layout false
  # skip_before_filter :verify_authenticity_token

  # respond_to :json, only: [:isolated]

  def metadata
    @entity = Entity.find(params[:id])

    if allowed_to?(:view, @entity.collection)
      send_data(Kor::Export::MetaData.new(current_user).render(@entity),
        type: 'text/plain',
        filename: "#{@entity.id}.txt"
      )
    else
      render_403
    end
  end

  # def gallery
  #   params[:include] = param_to_array(params[:include], ids: false)

  #   entities = viewable_entities.
  #     includes(:kind, :collection, :medium, :tags).
  #     media.
  #     newest_first

  #   @total = entities.count
  #   @per_page = 16
  #   @records = entities.pageit(params[:page], 16)
  # end
  
  # def invalid
  #   if authorized? :delete
  #     @per_page = 30
  #     group = SystemGroup.find_or_create_by(name: 'invalid')
  #     scope = group.entities.allowed(current_user, :delete)
  #     @total = scope.count
  #     @records = scope.pageit(page, per_page)

  #     render action: 'index'
  #   else
  #     render_403
  #   end
  # end
  
  # def recent
  #   params[:include] = param_to_array(params[:include], ids: false)

  #   if authorized? :edit
  #     @per_page = 30
  #     scope = Entity.
  #       includes(:creator, :updater, :collection, :kind, :tags).
  #       allowed(current_user, :edit).
  #       without_media.
  #       newest_first.
  #       within_collections(params[:collection_id])
  #     @total = scope.count
  #     @records = scope.pageit(page, per_page)

  #     render action: 'index'
  #   else
  #     render_403
  #   end
  # end

  # def isolated
  #   params[:include] = param_to_array(params[:include], ids: false)

  #   if authorized? :edit
  #     @per_page = 16
  #     scope = Entity.
  #       allowed(current_user, :view).
  #       isolated.
  #       newest_first.
  #       includes(:kind, :collection, :tags, :medium)

  #     @total = scope.count
  #     @records = scope.pageit(page, per_page)

  #     render action: 'index'
  #   else
  #     render_403
  #   end
  # end

  # def recently_created
  #   scope = Entity.
  #     allowed(current_user, :view).
  #     by_relation_name(params[:relation_name]).
  #     newest_first.includes(:kind)

  #   @total = scope.count
  #   @records = scope.pageit(page, per_page)

  #   render action: 'index'
  # end

  # def recently_visited
  #   history_entity_ids = current_user.history.map do |url|
  #     if m = url.match(/\/blaze\#\/entities\/(\d+)$/)
  #       m[1].to_i
  #     else
  #       nil
  #     end
  #   end

  #   scope = Entity.
  #     allowed(current_user, :view).
  #     by_ordered_id_array(history_entity_ids.reverse).
  #     by_relation_name(params[:relation_name]).
  #     includes(:kind).
  #     newest_first

  #   @total = scope.count
  #   @results = scope.pageit(page, per_page)

  #   render action: 'index'
  # end

  # def random
  #   params[:include] = param_to_array(params[:include], ids: false)

  #   scope = Entity.allowed(current_user, :view).media
  #   @total = scope.count

  #   amount = 4
  #   @records = if @total < amount
  #     scope.to_a
  #   else
  #     o = 0
  #     Array.new(amount).map do |i|
  #       o += [(rand(@total) / amount).round, 1].max
  #       scope.limit(1).offset(o).to_a.first
  #     end
  #   end

  #   render action: 'index'
  # end

  def index
    params[:id] = param_to_array(params[:id])
    params[:kind_id] = param_to_array(params[:kind_id])
    params[:related_per_page] = [
      (params[:related_per_page] || 1).to_i,
      Kor.settings['max_included_results_per_result']
    ].min
    params[:related_relation_name] = param_to_array(params[:related_relation_name], ids: false)
    params[:related_kind_id] = param_to_array(params[:related_kind_id])

    search = Kor::Search.new(current_user,
      terms: params[:terms],
      name: params[:name],
      id: params[:id],
      collection_id: params[:collection_id],
      authority_group_id: params[:authority_group_id],
      user_group_id: params[:user_group_id],
      kind_id: params[:kind_id],
      media: params[:media],
      relation_name: params[:relation_name],
      dating: params[:dating],

      isolated: params[:isolated],
      recent: params[:recent],

      sort: sort,

      page: page,
      per_page: per_page,
    )

    search.run

    @records = search.records
    @total = search.total
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

  # def relation_counts
  #   @relations = Entity.find(params[:id]).relation_counts(current_user)
  #   format.json {render json: @relations}
  # end

  # def new
  #   if authorized? :create, Collection.all, :required => :any
  #     @entity = Entity.new(:collection_id => current_user.default_collection_id)
  #     kind = Kind.find(params[:kind_id])
  #     @entity.kind = kind
  #     @entity.no_name_statement = 'enter_name'
  #     @entity.medium = Medium.new if @entity.kind_id == Kind.medium_kind.id
  #   else
  #     render_403
  #   end
  # end
  
  # def multi_upload
  #   render :layout => "blaze"
  # end

  # def edit
  #   @entity = Entity.find(params[:id])
  #   # @entity.datings.build label: @entity.kind.dating_label

  #   if authorized? :edit, @entity.collection
  #     render :action => 'edit'  
  #   else
  #     render_403
  #   end
  # end

  def create
    @entity = Entity.new
    @entity.kind_id = params[:entity][:kind_id]
    @entity.assign_attributes entity_params

    if allowed_to?(:create, @entity.collection)
      @entity.creator_id = current_user.id

      if @entity.save
        if params[:user_group_name]
          transit = UserGroup.owned_by(current_user).find_or_create_by(name: params[:user_group_name])
          transit.add_entities @entity if transit
        end

        if params[:target_entity_id].present? && params[:relation_name].present? && params[:relation_name] != 'false'
          relationship = Relationship.relate(@entity, params[:relation_name], params[:target_entity_id])
          if authorized_for_relationship?(relationship, :create)
            relationship.save!
          end
        end
        
        @record = @entity
        render_created @entity
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
          render_422 build_nested_errors(@entity)
        end
      end
    else
      render_403
    end
  end

  def update
    params[:entity][:existing_datings_attributes] ||= []

    @entity = Entity.find(params[:id])
    @entity.assign_attributes entity_params

    authorized = if @entity.collection_id_changed?
      allowed_to?(:delete, Collection.find(@entity.collection_id_was)) && 
      allowed_to?(:create, Collection.find(@entity.collection_id))
    else
      allowed_to?(:edit, @entity.collection)
    end
    
    if authorized
      @entity.updater_id = current_user.id

      if @entity.save
        SystemGroup.find_or_create_by(:name => 'invalid').remove_entities @entity
        render_updated @entity
      else
        render_422 build_nested_errors(@entity)
      end
    else
      if @entity.collection_id_changed?
        render_403 I18n.t('errors.move_denied')
      else
        render_403
      end
    end
  rescue ActiveRecord::StaleObjectError
    flash[:error] = I18n.t('activerecord.errors.messages.stale_entity_update')
    render action: 'edit'
  end

  def update_tags
    new_tags = params[:entity].permit(:tags)['tags'].presence || ""
    new_tags = new_tags.split(/,\s*/)
    @entity = Entity.find(params[:id])
    
    if allowed_to?(:tagging, @entity.collection)
      @entity.tag_list += new_tags
      
      if @entity.save
        render_200 I18n.t('objects.update_success',
          o: I18n.t('activerecord.models.tag', count: 'other')
        )
      else
        @errors = @entity.errors
        render_422
      end
    else
      render_403
    end
  end

  def destroy
    @entity = Entity.find(params[:id])
    if allowed_to?(:delete, @entity.collection)
      @entity.destroy
      flash[:notice] = I18n.t( 'objects.destroy_success', :o => @entity.display_name )
      if session[:current_entity] == @entity.id
        session[:current_entity] = nil
      end
      render_200 I18n.t('objects.destroy_success',
        o: I18n.t('activerecord.models.entity', count: 1)
      ) 
    else
      render_403
    end
  end

  def merge
    entities = Entity.find(params[:entity_ids])
    collections = entities.map{|e| e.collection}.uniq
    
    allowed_to_create = allowed_to?(:create)
    allowed_to_delete_requested_entities = allowed_to?(:delete, collections, :required => :all)
  
    if allowed_to_create and allowed_to_delete_requested_entities
      if entities.map{|e| e.kind.id}.uniq.size != 1
        render_422 nil, I18n.t('errors.only_same_kind')
      end

      @record = Kor::EntityMerger.new.run(
        :old_ids => params[:entity_ids], 
        :attributes => entity_params.merge(
          :creator_id => current_user.id
        )
      )
      
      if @record.valid?
        render_200 I18n.t('notices.merge_success')
      else
        render_422 @record.errors, I18n.t('errors.merge_failure')
      end
    else
      render_403 I18n.t("errors.merge_access_denied_on_entities")
    end
  end

  def mass_relate
    if params[:id].blank?
      render_422 I18n.t("errors.destination_not_given")
    else
      @target = Entity.find(params[:id])
      @entities = Entity.find(params[:entity_ids] || [])

      can_edit = 
        allowed_to?(:edit, @target.collection_id) || 
        allowed_to?(:edit, @entities.map{|e| e.collection_id})
      collections = [@target.collection_id] + @entities.map{|e| e.collection_id}
      can_view = allowed_to?(:view, collections, required: :all)

      if can_edit & can_view
        relationships = @entities.collect do |e|
          Relationship.relate(e, params[:relation_name], @target)
        end

        begin
          Relationship.transaction do
            relationships.each do |r|
              r.save!
            end
          end
        rescue ActiveRecord::Rollback => e
          render_422 I18n.t('errors.relationships_not_saved')
        end

        render_200 I18n.t('notices.mass_relation_success')
      else
        render_403 I18n.t('errors.source_or_target_not_editable')
      end
    end
  end

  def existence
    ids = params[:ids]
    found_ids = Entity.allowed(current_user).where(id: ids).map{|e| e.id}
    existence = found_ids.zip(Array.new(found_ids.size, true)).to_h
    ids = ids.zip(Array.new(ids.size, false)).to_h

    render json: ids.merge(existence)
  end

  protected

    def entity_params
      params.require(:entity).permit(
        # :id, # TODO: smart?
        :uuid, # TODO: smart?
        :lock_version,
        :kind_id,
        :collection_id,
        :name, :distinct_name, :subtype, :comment, :no_name_statement,
        :tag_list,
        :synonyms => [],
        :datings_attributes => [
          :id, :_destroy, :label, :dating_string, :lock_version
        ],
        :properties => [:label, :value],
        :medium_attributes => [:id, :image, :document]
      ).tap do |e|
        e[:dataset] = params[:entity][:dataset].try(:permit!)
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
