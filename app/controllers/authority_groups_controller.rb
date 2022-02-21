class AuthorityGroupsController < JsonController
  skip_before_action :auth, only: [:download_images, :index, :show]

  def index
    @records = AuthorityGroup.search(params[:terms])
    if params.has_key?(:authority_group_category_id)
      @records = @records.within_category(params[:authority_group_category_id])
    end

    @total = @records.count
    @records = @records.pageit(page, per_page)
    render 'json/index'
  end

  def download_images
    @record = AuthorityGroup.find(params[:id])
    @entities = @record.entities.allowed(current_user, :view).media

    zip_download @record, @entities
  end

  def add_to
    @record = AuthorityGroup.find(params[:id])
    entity_ids = Kor.array_wrap(params[:entity_ids])
    entities = Entity.allowed(current_user).find(entity_ids)
    @record.add_entities(entities)

    render_200 I18n.t('messages.entities_added_to_group')
  end

  def remove_from
    @record = AuthorityGroup.find(params[:id])
    entity_ids = Kor.array_wrap(params[:entity_ids])
    entities = Entity.allowed(current_user).find(entity_ids)
    @record.remove_entities(entities)

    render_200 I18n.t('messages.entities_removed_from_group')
  end

  def show
    @record = AuthorityGroup.find(params[:id])
    render template: 'json/show'
  end

  def create
    @record = AuthorityGroup.new(authority_group_params)

    if @record.save
      render_created @record
    else
      render_422 @record.errors
    end
  end

  def update
    @record = AuthorityGroup.find(params[:id])

    if @record.update(authority_group_params)
      render_updated @record
    else
      render_422 @record.errors
    end
  end

  # make sure this destroys all member associations
  def destroy
    @record = AuthorityGroup.find(params[:id])
    @record.destroy
    render_deleted @record
  end

  protected

    def authority_group_params
      params.fetch(:authority_group, {}).permit(:name, :lock_version, :authority_group_category_id)
    end

    def auth
      if action_name == 'mark'
        require_non_guest
      else
        require_authority_group_admin
      end
    end

    def cap_per_page
      false
    end
end
