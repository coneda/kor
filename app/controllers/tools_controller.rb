class ToolsController < JsonController
  
  skip_before_action :authentication, :only => 'history'
  skip_before_action :verify_authenticity_token, only: ['history', :mark_as_current]
  skip_before_filter :authorization, :except => [ 
    'remove_from_invalid_entities', 
    'add_to_authority_group', 
    'remove_from_authority_group' 
  ]

  # layout 'normal_small'


  def history
    history_store params[:url]
    render :nothing => true
  end

  # TODO: handle the whole clipboard functionality with localstorage, e.g.
  # https://github.com/tsironis/lockr
  # def clipboard
  #   params[:include] = param_to_array(params[:include], ids: false)
    
  #   @per_page = 500
  #   @records = viewable_entities.where(id: params[:ids])
  #   @total = @records.count

  #   render action: '../entities/index'
  # end

  # def mark_as_current
  #   if params[:id]
  #     session[:bla] = ',p'
  #     session[:current_history] ||= Array.new
  #     session[:current_history] << params[:id].to_i unless session[:current_history].last == params[:id].to_i
  #     session[:current_history] = session[:current_history].last(Kor.settings['current_history_length'].to_i)

  #     entity = viewable_entities.find(params[:id])
  #     entity_name = (entity.is_medium? ? entity.id : "'#{entity.display_name}'")

  #     session[:current_entity] = params[:id].to_i || nil
  #     flash[:notice] = I18n.t("objects.marked_as_current_success", :o => entity_name)
  #   else
  #     flash[:error] = I18n.t("objects.marked_as_current_failure", :o => entity_name)
  #   end

  #   respond_to do |format|
  #     format.html { redirect_to back_save }
  #     format.json do
  #       @current_history = session[:current_history].map{|id| Entity.includes(:medium).find(id)}
  #       @notice = flash[:notice]
  #       render
  #       flash.discard
  #     end
  #   end
  # end
  
  # TODO: write integration test for this but implement it within angularjs
  def add_media
    session[:current_entity] = params[:id].to_i || nil
    redirect_to "/blaze#/entities/multi_upload"
  end

  def mark
    if params[:mark] == 'reset'
      flash[:notice] = I18n.t("notices.reset_clipboard_success")
      current_user.clipboard_reset
    else
      entity = viewable_entities.find(params[:id])
      entity_name = (entity.is_medium? ? entity.id : "'#{entity.display_name}'")
    
      if current_user && !current_user.guest?
        if params[:mark] == 'mark'
          current_user.clipboard_add(params[:id])
          flash[:notice] = I18n.t("objects.marked_entity_success", :o => entity_name)
        elsif params[:mark] == 'unmark'
          flash[:notice] = I18n.t("objects.unmarked_entity_success", :o => entity_name)
          current_user.clipboard_remove(params[:id])
        else
          raise "invalid mark operation: #{params[:mark]}"
        end
      else
        raise 'no user logged in, clipboard unavailable'
      end
    end

    respond_to do |format|
      format.html do 
        if request.referer && request.referer.match(/\/blaze/)
          redirect_to back_save
        elsif request.referer && request.referer.match(/\/authority_group/)
          redirect_to :back
        else
          redirect_to :controller => 'tools', :action => 'clipboard'
        end
      end
      format.json do
        message = flash[:notice]
        render :json => {:message => message, :clipboard => current_user.clipboard}
        flash.discard
      end
    end
  end

  def session_info
    session[:show_session_info] = (params[:show] == 'show')
    render :nothing => true
  end
  
  def groups_menu
    session[:expand_group_menu] = (params[:folding] == 'expand')
    render :nothing => true
  end

  def dataset_fields
    begin
      @kind = Kind.find(params[:kind_id])
      render :partial => 'fields/search/all', :locals => {
        :search => kor_graph.search(:attribute, :criteria => {:kind_id => params[:kind_id]})
      }
    rescue ActiveRecord::RecordNotFound => e
      render :nothing => true
    end
  end
  
  def relational_form_fields
    @kind_id = params[:kind_id]
    
    render :layout => false
  end
  
  
  ####################### clipboard action handling ############################

  # prepares the clipboard action form with additional functionality needed to
  # carry out some clioboard_actions
  def new_clipboard_action
    case params[:clipboard_action]
      when 'choose'
        render :nothing => true
      when 'prepare_merge' then render :nothing => true
      when 'mass_relate'
        unless session[:current_entity].blank?
          @selected_entities = Entity.where(:id => params[:selected_entity_ids])
          render :action => 'mass_relate', :layout => false
        else
          render :text => I18n.t("errors.destination_not_given")
        end
      when 'mass_destroy' then render :nothing => true
      when 'add_to_authority_group' then render :action => 'add_to_authority_group'
      when 'add_to_user_group' then render :action => 'add_to_user_group'
      when 'move_to_collection' then render :action => 'move_to_collection', :layout => false
      else render :text => I18n.t('nouns.unkown_action')
    end
  end

  # actually carries out the clioboard actions. the type of action is
  # determined by <tt>params[:clioboard_action]</tt>
  def clipboard_action
    case params[:clipboard_action]
      when 'choose'
        flash[:notice] = I18n.t('messages.no_clipboard_action_selected')
        redirect_to back_save
      when 'prepare_merge' then prepare_merge
      when 'mass_relate' then mass_relate
      when 'mass_destroy' then mass_destroy
      when 'merge' then merge
      when 'add_to_authority_group' then add_to_authority_group
      when 'add_to_user_group' then add_to_user_group
      when 'remove_from_authority_group' then remove_from_authority_group
      when 'remove_from_user_group' then remove_from_user_group
      when 'move_to_collection' then move_to_collection
      else
        raise "unknown clipboard action requested"
    end
  end
  

  ####################### actual clipboard actions #############################

  def mass_delete
    if params[:ids]
      Entity.allowed(current_user, :delete).by_id(params[:ids]).destroy_all
      render_200 I18n.t('notices.entities_destroyed')
    else
      render_406 nil, I18n.t('nothing_selected')
    end
  end

  private
    def move_to_collection
      entities = Entity.find(params[:entity_ids])
      collection = Collection.find(params[:collection_id])
      acl_delete = authorized?(:delete, entities.map{|e| e.collection})
      acl_create = authorized?(:create, collection)
      
      if acl_delete && acl_create
        Entity.where(:id => params[:entity_ids]).update_all :collection_id => params[:collection_id]
        flash[:notice] = I18n.t('messages.entities_moved_to_collection', :o => collection.name)
        redirect_to clipboard_path
      else
        render_403
      end
    end
  
    def add_to_authority_group
      if current_user.authority_group_admin?
        if params[:group_id]
          @group = AuthorityGroup.find(params[:group_id])
          @entities = viewable_entities.find(params[:entity_ids])
          @group.add_entities(@entities)

          if @group.save
            redirect_to authority_group_path(@group)
          else
            redirect_to back_save
          end
        else
          flash[:error] = I18n.t('messages.no_authority_groups')
          redirect_to back_save
        end
      else
        render_403
      end
    end

    def remove_from_authority_group
      if current_user.authority_group_admin?
        @group = AuthorityGroup.find(params[:group_id])
        @entities = viewable_entities.find(params[:entity_ids])
        @group.remove_entities(@entities)

        if @group.save
          redirect_to authority_group_path(@group)
        else
          redirect_to back_save
        end
      else
        render_403
      end
    end

    def add_to_user_group
      if params[:group_id]
        @group = UserGroup.owned_by(current_user).find(params[:group_id])
        @entities = viewable_entities.find(params[:entity_ids])
        @group.add_entities(@entities)

        if @group.save
          redirect_to user_group_path(@group)
        else
          redirect_to back_save
        end
      else
        flash[:error] = I18n.t('messages.no_user_groups')
        redirect_to back_save
      end
    end

    def remove_from_user_group
      @group = UserGroup.owned_by(current_user).find(params[:group_id])
      @entities = viewable_entities.find(params[:entity_ids])
      @group.remove_entities(@entities)

      if @group.save
        redirect_to user_group_path(@group)
      else
        redirect_to back_save
      end
    end

    def prepare_merge
      @entities = Entity.allowed(current_user, [:edit, :delete]).where(:id => params[:entity_ids])
      
      if @entities.blank?
        flash[:error] = I18n.t("errors.merge_access_denied_on_entities")
        render_403
      elsif @entities.collect{|e| e.kind.id}.uniq.size != 1
        flash[:error] = I18n.t("errors.only_same_kind")
        redirect_to :controller => 'tools', :action => 'clipboard', :entity_ids => params[:entity_ids]
      else
        kind = @entities.first.kind
        @entity = Entity.new(:kind => kind)
        render :action => 'merge'
      end
    end

    def mass_relate
      if session[:current_entity].blank?
        flash[:error] = I18n.t("errors.destination_not_given")
        redirect_to back_save
      else
        @entities = Entity.allowed(current_user, :edit).find(params[:entity_ids] || [])
        @target = Entity.allowed(current_user, :view).find(session[:current_entity])

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
          flash[:error] = I18n.t('errors.relationships_not_saved')
          redirect_to back_save
        end

        redirect_to web_path(:anchor => entity_path(@target))
      end
    end
  
    def merge
      entities = Entity.find(params[:entity_ids])
      collections = entities.map{|e| e.collection}.uniq
      
      allowed_to_create = authorized?(:create)
      allowed_to_delete_requested_entities = authorized?(:delete, collections, :required => :all)
    
      if allowed_to_create and allowed_to_delete_requested_entities
        @entity = Kor::EntityMerger.new.run(
          :old_ids => params[:entity_ids], 
          :attributes => entity_params.merge(
            :id => params[:entity][:id],
            :creator_id => current_user.id
          )
        )
        
        if @entity.valid?
          flash[:notice] = I18n.t('notices.merge_success')
          redirect_to web_path(:anchor => "/entities/#{@entity.id}")
        else
          flash[:error] = I18n.t('errors.merge_failure')
          redirect_to :action => 'clipboard'
        end
      else
        render_403
      end
    end

end
