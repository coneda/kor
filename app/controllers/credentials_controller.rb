class CredentialsController < JsonController
  def index
    # TODO: unify this
    params[:sort_by] ||= 'name'
    params[:sort_order] ||= 'ASC'

    @records = Credential.
      non_personal.
      order(params[:sort_by] => params[:sort_order])
    
    params[:per_page] = @records.count
    @total = @records.count

    render template: 'json/index'
  end

  def show
    @record = Credential.find(params[:id])
    render template: 'json/show'
  end

  def create
    @record = Credential.new(credential_params)

    if @record.save
      render_created @record
    else
      render_422 @record.errors
    end
  end

  def update
    @record = Credential.find(params[:id])

    if @record.update_attributes(credential_params)
      render_updated @record
    else
      render_422 @record.errors
    end
  end

  def destroy
    @record = Credential.find(params[:id])
    @record.destroy
    render_deleted @record
  end
  
  protected

    def credential_params
      params.require(:credential).permit!
    end

    def auth
      require_admin
    end
    
end
