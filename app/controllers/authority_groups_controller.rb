class AuthorityGroupsController < JsonController
  # layout 'normal_small'
  
  skip_before_filter :authorization, :only => [:download_images, :index, :show]

  def index
    if params[:authority_group_category_id] == ''
      params[:authority_group_category_id] = 'root'
    end

    @records = AuthorityGroup.
      within_category(params[:authority_group_category_id]).
      search(params[:terms])
    
    @total = @records.count
    @records = @records.pageit(page, per_page)
    render 'json/index'
  end

  def mark
    @authority_group = AuthorityGroup.find(params[:id])
    ids = @authority_group.entities.allowed(current_user, :view).map{|e| e.id}

    current_user.clipboard_add ids
    
    flash[:notice] = I18n.t("objects.marked_entities_success")
    
    redirect_to :action => 'show'
  end
  
  def download_images
    @authority_group = AuthorityGroup.find(params[:id])
    @entities = @authority_group.entities.allowed(current_user, :view).media
    
    zip_download @authority_group, @entities
  end
  
  def add_to
    @authority_group = AuthorityGroup.find_or_create_by!(name: params[:group_name])
    entity_ids = Kor.array_wrap(params[:entity_ids])
    entities = viewable_entities.find entity_ids
    @authority_group.add_entities(entities)

    @record = @authority_group
    render_200 I18n.t('messages.entities_added_to_group')
  end

  def remove_from
    @authority_group = AuthorityGroup.find(params[:id])
    entity_ids = Kor.array_wrap(params[:entity_ids])
    entities = viewable_entities.find entity_ids
    @authority_group.remove_entities(entities)

    redirect_to @authority_group
  end
  
  def show
    @record = AuthorityGroup.find(params[:id])
    render template: 'json/show'
    # @entities = @authority_group.
    #   entities.
    #   allowed(current_user, :view).
    #   paginate(:page => params[:page], :per_page => 16).
    #   order('created_at DESC')
  end

  # def new
  #   @authority_group = AuthorityGroup.new(authority_group_params)
  # end

  # def edit
  #   @authority_group = AuthorityGroup.find(params[:id])
  # end
  
  # def edit_move
  #   @authority_group = AuthorityGroup.find(params[:id])
  # end

  def create
    @record = AuthorityGroup.new(authority_group_params)

    if @record.save
      render_200 I18n.t('objects.create_success', :o => @record.name)
    else
      render_406 @record.errors
    end
  end

  def update
    @authority_group = AuthorityGroup.find(params[:id])

    if @authority_group.update_attributes(authority_group_params)
      render_200 I18n.t('objects.update_success', :o => @authority_group.name)
    else
      render_406 @authority_group.errors
    end
  end

  # make sure this destroys all member associations
  def destroy
    @authority_group = AuthorityGroup.find(params[:id])
    @authority_group.destroy
    render_200 I18n.t('objects.destroy_success', :o => @authority_group.name)
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
    
end
