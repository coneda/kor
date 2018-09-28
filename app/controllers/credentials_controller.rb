class CredentialsController < JsonController
  
  def index
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

  # def new
  #   @credential = Credential.new
  # end

  # def edit
  #   @credential = Credential.find(params[:id])
  # end

  def create
    @credential = Credential.new(credential_params)

    if @credential.save
      render_200 I18n.t('objects.create_success', :o => @credential.name)
    else
      render_406 @credential.errors
    end
  end

  def update
    @credential = Credential.find(params[:id])

    if @credential.update_attributes(credential_params)
      render_200 I18n.t('objects.update_success', :o => @credential.name)
    else
      render_406 @credential.errors
    end
  end

  def destroy
    @credential = Credential.find(params[:id])
    @credential.destroy
    render_200 I18n.t('objects.destroy_success', :o => @credential.name)
  end
  
  protected

    def credential_params
      params.require(:credential).permit!
    end

    def auth
      require_admin
    end
  
end
