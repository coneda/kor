class CredentialsController < JsonController
  # layout 'normal_small'
  
  def index
    params[:sort_by] ||= 'name'
    params[:sort_order] ||= 'ASC'

    @records = Credential.
      non_personal.
      order(params[:sort_by] => params[:sort_order])
    @per_page = @records.count    
    @total = @records.count
  end

  def show
    @credential = Credential.find(params[:id])
  end

  def new
    @credential = Credential.new
  end

  def edit
    @credential = Credential.find(params[:id])
  end

  def create
    @credential = Credential.new(credential_params)

    if @credential.save
      flash[:notice] = I18n.t('objects.create_success', :o => @credential.name)
      redirect_to credentials_path
    else
      render :action => "new"
    end
  end

  def update
    @credential = Credential.find(params[:id])

    if @credential.update_attributes(credential_params)
      flash[:notice] = I18n.t('objects.update_success', :o => @credential.name)
      redirect_to credentials_path
    else
      render :action => "edit"
    end
  end

  def destroy
    @credential = Credential.find(params[:id])
    @credential.destroy
    
    redirect_to(credentials_path)
  end
  
  protected

    def credential_params
      params.require(:credential).permit!
    end

    def generally_authorized?
      current_user.admin?
    end
  
end
