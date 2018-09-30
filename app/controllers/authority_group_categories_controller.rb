class AuthorityGroupCategoriesController < JsonController
  # layout 'small_normal'
  
  skip_before_filter :auth, :only => [:index, :show, :flat]

  def flat
    @records = AuthorityGroupCategory.all
    @total = @records.count
    render 'json/index'
  end
  
  def index
    @records = if params[:parent_id].present?
      AuthorityGroupCategory.find(params[:parent_id]).children
    else
      AuthorityGroupCategory.roots
    end

    @total = @records.count
    render template: 'json/index'
  end

  def show
    @record = AuthorityGroupCategory.find(params[:id])
    render template: 'json/show'
  end

  # def new
  #   @authority_group_category = AuthorityGroupCategory.new
  #   render :layout => 'normal_small'
  # end

  # def edit
  #   @authority_group_category = AuthorityGroupCategory.find(params[:id])
  #   render :layout => 'normal_small'
  # end

  def create
    @record = AuthorityGroupCategory.new(authority_group_category_params)

    if @record.save
      if params[:parent_id].present?
        @record.move_to_child_of(AuthorityGroupCategory.find(params[:parent_id]))
        @record.save
      end

      render_200 I18n.t('objects.create_success', :o => @record.name)
    else
      render_406 @record.errors
    end
  end

  def update
    @authority_group_category = AuthorityGroupCategory.find(params[:id])

    if @authority_group_category.update_attributes(authority_group_category_params)
      render_200 I18n.t('objects.update_success', :o => @authority_group_category.name)
    else
      render_406 @authority_group_category.errors
    end
  end

  # make sure this destroys all authority groups and their member associations
  def destroy
    @authority_group_category = AuthorityGroupCategory.find(params[:id])
    @authority_group_category.destroy
    render_200 I18n.t('objects.destroy_success', :o => @authority_group_category.name)
  end
  
  protected

    def authority_group_category_params
      params.require(:authority_group_category).permit(:name, :parent_id)
    end

    def auth
      require_authority_group_admin
    end

end
