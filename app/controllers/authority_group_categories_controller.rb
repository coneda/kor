class AuthorityGroupCategoriesController < JsonController
  skip_before_action :auth, :only => [:index, :show, :flat]

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

  def create
    @record = AuthorityGroupCategory.new(authority_group_category_params)

    if @record.save
      if params[:parent_id].present?
        @record.move_to_child_of(AuthorityGroupCategory.find(params[:parent_id]))
        @record.save
      end

      render_created @record
    else
      render_422 @record.errors
    end
  end

  def update
    @record = AuthorityGroupCategory.find(params[:id])

    if @record.update_attributes(authority_group_category_params)
      render_updated @record
    else
      render_422 @record.errors
    end
  end

  # make sure this destroys all authority groups and their member associations
  def destroy
    @record = AuthorityGroupCategory.find(params[:id])
    @record.destroy
    render_deleted @record
  end

  protected

    def authority_group_category_params
      params.require(:authority_group_category).permit(:name, :parent_id)
    end

    def auth
      require_authority_group_admin
    end
end
