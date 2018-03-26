class UserGroupsController < JsonController
  layout 'normal_small'

  before_filter :pagination, only: ['index']
  
  def mark
    @user_group = UserGroup.owned_by(current_user).find_by_id(params[:id])
    @user_group ||= UserGroup.shared.find(params[:id])
    ids = @user_group.entities.allowed(current_user, :view).map{|e| e.id}

    current_user.clipboard_add ids
    
    flash[:notice] = I18n.t("objects.marked_entities_success")
    
    redirect_to :action => 'show'
  end
  
  def download_images
    @user_group = UserGroup.find(params[:id])
    
    if @user_group.owner == current_user or @user_group.shared
      @entities = @user_group.entities.allowed(current_user, :view).media
      
      zip_download @user_group, @entities
    else
      flash[:error] = I18n.t('errors.access_denied')
      render_403
    end
  end

  def add_to
    @user_group = UserGroup.owned_by(current_user).find(params[:id])
    entity_ids = Kor.array_wrap(params[:entity_ids])
    entities = viewable_entities.find entity_ids
    @user_group.add_entities(entities)
    
    redirect_to @user_group
  end

  def remove_from
    @user_group = UserGroup.owned_by(current_user).find(params[:id])
    entity_ids = Kor.array_wrap(params[:entity_ids])
    entities = viewable_entities.find entity_ids
    @user_group.remove_entities(entities)

    redirect_to @user_group
  end
  
  def share
    @user_group = if current_user.admin?
      UserGroup.find(params[:id])
    else
      UserGroup.owned_by(current_user).find(params[:id])
    end

    @user_group.shared = true
    @user_group.save
    flash[:notice] = I18n.t('objects.shared_success', :o => @user_group.name)
    redirect_to :back
  end
  
  def unshare
    @user_group = if current_user.admin?
      UserGroup.find(params[:id])
    else
      UserGroup.owned_by(current_user).find(params[:id])
    end

    @user_group.shared = false
    @user_group.save
    flash[:notice] = I18n.t('objects.unshared_success', :o => @user_group.name)
    redirect_to :back
  end
  
  def shared
    @user_groups = UserGroup.shared
  end

  def index
    @records = UserGroup.owned_by(current_user).search(params[:terms])
    
    if params[:term]
      @records = @user_groups.named_like(params[:term])
    end
    
    @total = @records.count
    @records = @records.pageit(@page, @per_page)
  end

  def show
    @user_group = UserGroup.find(params[:id])
    
    if @user_group.owner == current_user or @user_group.shared
      @entities = @user_group.
        entities.allowed(current_user, :view).
        order('created_at DESC').
        paginate(:page => params[:page], :per_page => 16)
      render :layout => 'wide'
    else
      flash[:error] = I18n.t('errors.access_denied')
      render_403
    end
  end

  def new
    @user_group = UserGroup.new
  end

  # TODO: remove all edit actions from resources. They are not needed anymore
  # def edit
  #   @user_group = UserGroup.find(params[:id])
  # end

  def create
    @user_group = UserGroup.new(user_group_params)
    @user_group.user_id = current_user.id

    if @user_group.save
      render_200 I18n.t('objects.create_success', o: @user_group.name)
    else
      render_406 @user_group.errors
    end
  end

  def update
    @user_group = UserGroup.owned_by(current_user).find(params[:id])

    if @user_group.update_attributes(user_group_params)
      render_200 I18n.t('objects.update_success', o: @user_group.name)
    else
      render_406 @user_group.errors
    end
  end

  def destroy
    @user_group = UserGroup.owned_by(current_user).find(params[:id])
    @user_group.destroy

    render_200 I18n.t('objects.destroy_success', o: @user_group.name)
  end
  
  protected
    def generally_authorized?
      action_name == 'shared' || (current_user && current_user != User.guest)
    end

    def user_group_params
      params.require(:user_group).permit(:name, :lock_version)
    end
  
end
