class KindsController < ApplicationController
  layout 'normal_small'

  def index
    @kinds = Kind.all

    respond_to do |format|
      format.html {render :layout => 'wide'}
      format.json {render :json => @kinds}
    end
  end

  def show
    @kind = Kind.find(params[:id])
    
    respond_to do |format|
      format.json do
        render :json => @kind
      end
    end
  end

  def new
    @kind = Kind.new
  end

  def edit
    @kind = Kind.find(params[:id])
  end
  
  def create
    @kind = Kind.new(kind_params)

    if @kind.save
      flash[:notice] = I18n.t( 'objects.create_success', :o => Kind.model_name.human )
      redirect_to(@kind)
    else
      render :action => "new"
    end
  end

  def update
    @kind = Kind.find(params[:id])

    params[:kind][:settings][:tagging] ||= false
    
    if @kind.update_attributes(kind_params)
      flash[:notice] = I18n.t( 'objects.update_success', :o => Kind.model_name.human )
      redirect_to :action => 'index'
    else
      render :action => "edit"
    end
  end

  def destroy
    @kind = Kind.find(params[:id])
    
    unless @kind == Kind.medium_kind
      @kind.destroy
      redirect_to(kinds_url)
    else
      redirect_to denied_path
    end
  end
  
  
  protected
    
    def kind_params
      params.require(:kind).permit!
    end

    def generally_authorized?
      if action_name == 'index'
        true
      else
        current_user.kind_admin?
      end
    end

end
