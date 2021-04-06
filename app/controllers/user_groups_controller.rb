class UserGroupsController < JsonController
  def download_images
    @user_group = UserGroup.find(params[:id])

    if @user_group.owner == current_user or @user_group.shared
      @entities = @user_group.entities.allowed(current_user, :view).media

      zip_download @user_group, @entities
    else
      render_403 I18n.t('messages.access_denied')
    end
  end

  def add_to
    @records = UserGroup.owned_by(current_user).find(params[:id])
    entity_ids = Kor.array_wrap(params[:entity_ids])
    entities = Entity.allowed(current_user).find(entity_ids)
    @records.add_entities(entities)

    render_200 I18n.t('messages.entities_added_to_group')
  end

  def remove_from
    @records = UserGroup.owned_by(current_user).find(params[:id])

    entity_ids = Kor.array_wrap(params[:entity_ids])
    entities = Entity.allowed(current_user).find entity_ids
    @records.remove_entities(entities)

    render_200 I18n.t('messages.entities_removed_from_group')
  end

  def share
    @records = if current_user.admin?
      UserGroup.find(params[:id])
    else
      UserGroup.owned_by(current_user).find(params[:id])
    end

    @records.shared = true
    @records.save

    render_200 I18n.t('objects.shared_success', :o => @records.name)
  end

  def unshare
    @records = if current_user.admin?
      UserGroup.find(params[:id])
    else
      UserGroup.owned_by(current_user).find(params[:id])
    end

    @records.shared = false
    @records.save

    render_200 I18n.t('objects.unshared_success', :o => @records.name)
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

  def create
    @record = UserGroup.new(user_group_params)
    @record.user_id = current_user.id

    if @record.save
      render_created @record
    else
      render_422 @record.errors
    end
  end

  def update
    @record = UserGroup.owned_by(current_user).find(params[:id])

    if @record.update_attributes(user_group_params)
      render_updated @record
    else
      render_422 @record.errors
    end
  end

  def destroy
    @record = UserGroup.owned_by(current_user).find(params[:id])
    @record.destroy
    render_deleted @record
  end

  protected

    def auth
      ['shared', 'show', 'download_images'].include?(action_name) ||
        require_non_guest
    end

    def user_group_params
      params.require(:user_group).permit(:name, :lock_version)
    end

    def cap_per_page
      false
    end
end
