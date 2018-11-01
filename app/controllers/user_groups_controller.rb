class UserGroupsController < JsonController
  # layout 'normal_small'

  # def mark
  #   @user_group = UserGroup.owned_by(current_user).find_by_id(params[:id])
  #   @user_group ||= UserGroup.shared.find(params[:id])
  #   ids = @user_group.entities.allowed(current_user, :view).map{|e| e.id}

  #   current_user.clipboard_add ids
    
  #   flash[:notice] = I18n.t("objects.marked_entities_success")
    
  #   redirect_to :action => 'show'
  # end
  
  def download_images
    @user_group = UserGroup.find(params[:id])

    if @user_group.owner == current_user or @user_group.shared
      @entities = @user_group.entities.allowed(current_user, :view).media
      
      zip_download @user_group, @entities
    else
      render_403 I18n.t('errors.access_denied')
    end
  end

  def add_to
    @user_group = UserGroup.owned_by(current_user).find_or_create_by!(
      name: params[:group_name],
      owner: current_user
    )
    entity_ids = Kor.array_wrap(params[:entity_ids])
    entities = Entity.allowed(current_user).find(entity_ids)
    @user_group.add_entities(entities)

    @record = @user_group
    render_200 I18n.t('messages.entities_added_to_group')
  end

  def remove_from
    @user_group = UserGroup.owned_by(current_user).find(params[:id])
    
    entity_ids = Kor.array_wrap(params[:entity_ids])
    entities = Entity.allowed(current_user).find entity_ids
    @user_group.remove_entities(entities)

    render_200 I18n.t('messages.entities_removed_from_group')
  end
  
  def share
    @user_group = if current_user.admin?
      UserGroup.find(params[:id])
    else
      UserGroup.owned_by(current_user).find(params[:id])
    end

    @user_group.shared = true
    @user_group.save

    render_200 I18n.t('objects.shared_success', :o => @user_group.name)
  end
  
  def unshare
    @user_group = if current_user.admin?
      UserGroup.find(params[:id])
    else
      UserGroup.owned_by(current_user).find(params[:id])
    end

    @user_group.shared = false
    @user_group.save

    render_200 I18n.t('objects.unshared_success', :o => @user_group.name)
  end
  
  def shared
    @records = UserGroup.shared

    @total = @records.count
    @records = @records.pageit(page, per_page)
    render template: 'json/index'
  end

  def index
    @records = UserGroup.owned_by(current_user).search(params[:terms])
    
    @total = @records.count
    @records = @records.pageit(page, per_page)
    render template: 'json/index'
  end

  def show
    @record = UserGroup.find(params[:id])
    
    if @record.owner == current_user || @record.shared
      render template: 'json/show'
    else
      render_403
    end
  end

  # def new
  #   @user_group = UserGroup.new
  # end

  # TODO: remove all edit actions from resources. They are not needed anymore
  # def edit
  #   @user_group = UserGroup.find(params[:id])
  # end

  def create
    @record = UserGroup.new(user_group_params)
    @record.user_id = current_user.id

    if @record.save
      render_200 I18n.t('objects.create_success', o: @record.name)
    else
      render_422 @record.errors
    end
  end

  def update
    @record = UserGroup.owned_by(current_user).find(params[:id])

    if @record.update_attributes(user_group_params)
      render_200 I18n.t('objects.update_success', o: @record.name)
    else
      render_422 @record.errors
    end
  end

  def destroy
    @record = UserGroup.owned_by(current_user).find(params[:id])
    @record.destroy

    render_200 I18n.t('objects.destroy_success', o: @record.name)
  end
  
  protected

    def auth
      ['shared', 'show', 'download_images'].include?(action_name) || 
      require_non_guest
    end

    def user_group_params
      params.require(:user_group).permit(:name, :lock_version)
    end
  
end
