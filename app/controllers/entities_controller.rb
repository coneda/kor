class EntitiesController < JsonController
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

  def index
    params[:id] = param_to_array(params[:id])
    params[:kind_id] = param_to_array(params[:kind_id])
    params[:except_kind_id] = param_to_array(params[:except_kind_id])
    params[:related_per_page] = [
      (params[:related_per_page] || 1).to_i,
      Kor.settings['max_included_results_per_result']
    ].min
    params[:related_relation_name] = param_to_array(params[:related_relation_name], ids: false)
    params[:related_kind_id] = param_to_array(params[:related_kind_id])

    criteria = {
      name: params[:name],
      id: params[:id],
      collection_id: params[:collection_id],
      kind_id: params[:kind_id],
      except_kind_id: params[:except_kind_id],
      dating: params[:dating],
      tags: param_to_array(params[:tags], ids: false),
      relation_name: params[:relation_name],

      file_name: params[:file_name],
      file_type: params[:file_type],
      datahash: params[:datahash],

      created_after: param_to_time(params[:created_after]),
      created_before: param_to_time(params[:created_before]),
      updated_after: param_to_time(params[:updated_after]),
      updated_before: param_to_time(params[:updated_before]),
      updated_by: params[:updated_by],
      created_by: params[:created_by],

      isolated: param_to_boolean(params[:isolated]),
      invalid: param_to_boolean(params[:invalid]),

      user_group_id: params[:user_group_id],
      authority_group_id: params[:authority_group_id],

      terms: params[:terms],
      dataset: dataset_params,
      property: params[:property],
      related: params[:related],

      sort: sort,

      page: page,
      per_page: per_page,
    }

    if params[:file_size].present?
      regex = /^([+\-])?(\d+)\s*(kb|mb|gb|tb)?$/
      x, sign, size, unit = params[:file_size].downcase.match(regex).to_a
      if size
        if unit
          exp = {'kb' => 1, 'mb' => 2, 'gb' => 3, 'tb' => 3}[unit] || 0
          size = size.to_i * 1024**exp
        end
        key = {'+' => :larger_than, '-' => :smaller_than}[sign] || :file_size
        criteria[key] = size.to_i
      end
    end

    criteria = criteria.delete_if do |_k, v|
      ['', nil, -1, [], {}].include?(v)
    end

    search = Kor::Search.new(current_user, criteria)

    @engine = search.engine
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

    unless allowed_to?(:view, @entity.collection)
      render_403
    end
  end

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
        condition =
          @entity.medium &&
          @entity.medium.errors[:datahash].present? &&
          params[:user_group_name]
        if condition
          transit = UserGroup.owned_by(current_user).find_or_create_by(name: params[:user_group_name])

          if transit
            @entity = Medium.where(datahash: @entity.medium.datahash).first.entity
            transit.add_entities @entity
            render_created @entity and return
          end
        end

        render_422 build_nested_errors(@entity)
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
        render_403 I18n.t('messages.move_denied')
      else
        render_403
      end
    end
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
      if session[:current_entity] == @entity.id
        session[:current_entity] = nil
      end
      render_deleted @entity
    else
      render_403
    end
  end

  def merge
    entities = Entity.find(params[:entity_ids])
    collections = entities.map{ |e| e.collection }.uniq

    allowed_to_create = allowed_to?(:create)
    allowed_to_delete_requested_entities = allowed_to?(:delete, collections, :required => :all)

    if allowed_to_create and allowed_to_delete_requested_entities
      if entities.map{ |e| e.kind.id }.uniq.size != 1
        render_422 nil, I18n.t('messages.only_same_kind')
      end

      @record = Kor::EntityMerger.new.run(
        :old_ids => params[:entity_ids],
        :attributes => entity_params.merge(
          :creator_id => current_user.id
        )
      )

      if @record.valid?
        render_200 I18n.t('messages.merge_success')
      else
        render_422 @record.errors, I18n.t('messages.merge_failure')
      end
    else
      render_403 I18n.t("messages.merge_access_denied_on_entities")
    end
  end

  def mass_relate
    if params[:id].blank?
      render_422 I18n.t("messages.destination_not_given")
    else
      @target = Entity.find(params[:id])
      @entities = Entity.find(params[:entity_ids] || [])

      can_edit =
        allowed_to?(:edit, @target.collection_id) ||
        allowed_to?(:edit, @entities.map{ |e| e.collection_id })
      collections = [@target.collection_id] + @entities.map{ |e| e.collection_id }
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
        rescue ActiveRecord::Rollback
          render_422 I18n.t('messages.relationships_not_saved') and return
        end

        render_200 I18n.t('messages.mass_relation_success')
      else
        render_403 I18n.t('messages.source_or_target_not_editable')
      end
    end
  end

  def mass_destroy
    @entities = Entity.find(params[:ids])

    if allowed_to?(:delete, @entities.map{|e| e.collection_id})
      @entities.each{|e| e.destroy}
      render_200 I18n.t('messages.mass_destroy_success')
    else
      render_403 I18n.t('messages.not_all_entities_deletable')
    end
  end

  def existence
    ids = params[:ids]
    found_ids = Entity.allowed(current_user).where(id: ids).map{ |e| e.id }
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
      result = entity.errors.as_json

      de = {}
      result.each do |k, v|
        if k.to_s.match(/^dataset\./)
          n = k.to_s.split(/\./).last
          de[n] ||= []
          de[n] << v
        end
      end

      result.reject! do |k, _v|
        k.match(/^datings/) || k.match(/^dataset\./)
      end

      result.merge!(
        'datings' => entity.datings.map{ |d| d.errors.as_json },
        'dataset' => de
      )

      result
    end

    def dataset_params
      results = {}
      params.each do |k, v|
        if m = k.match(/^dataset_(.+)$/)
          results[m[1]] = v
        end
      end
      results
    end
end
