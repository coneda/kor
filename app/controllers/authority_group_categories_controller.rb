class AuthorityGroupCategoriesController < JsonController
  skip_before_action :auth, only: [:index, :show, :flat]

  def flat
    @records = records.all
    @total = @records.count
    render 'json/index'
  end

  def index
    @records = if params[:parent_id].present?
      records.find(params[:parent_id]).children
    else
      records.roots
    end


    @total = @records.count
    @records = @records.pageit(page, per_page)
    render template: 'json/index'
  end

  def show
    @record = records.find(params[:id])
    render template: 'json/show'
  end

  def create
    @record = records.new(authority_group_category_params)

    if @record.save
      if params[:parent_id].present?
        @record.move_to_child_of(records.find(params[:parent_id]))
        @record.save
      end

      render_created @record
    else
      render_422 @record.errors
    end
  end

  def update
    @record = records.find(params[:id])

    if @record.update(authority_group_category_params)
      render_updated @record
    else
      render_422 @record.errors
    end
  end

  # make sure this destroys all authority groups and their member associations
  def destroy
    @record = records.find(params[:id])
    @record.destroy
    render_deleted @record
  end

  protected

    def authority_group_category_params
      params.require(:authority_group_category).permit(:name, :parent_id)
    end

    def records
      AuthorityGroupCategory.order(name: 'asc')
    end

    def auth
      require_authority_group_admin
    end

    def cap_per_page
      false
    end
end
