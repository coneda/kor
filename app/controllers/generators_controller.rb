class GeneratorsController < ApplicationController

  layout 'small_normal'

  before_filter do
    @kind = Kind.find(params[:kind_id])
    @generators = @kind.generators
  end
  
  def index
    
  end

  def show
    @generator = Generator.find(params[:id])
    render :inline => @generator.directive
  end
  
  def new
    @generator = Generator.new(generator_params)
    @generator.kind = @kind
  end
  
  def edit
    @generator = @generators.find(params[:id])
  end
  
  def update
    @generator = @generators.find(params[:id])

    if @generator.update_attributes(generator_params)
      flash[:notice] = I18n.t('objects.update_success', :o => @generator.name)
      redirect_to :action => 'index'
    else
      render :action => 'edit'
    end
  end
  
  def create
    @generator = @generators.new(generator_params)
    
    if @generator.save
      flash[:notice] = I18n.t('objects.create_success', :o => @generator.name)
      redirect_to :action => 'index'
    else
      render :action => 'new'
    end
  end
  
  def destroy
    @generator = @generators.find(params[:id])
    @generator.destroy
    flash[:notice] = I18n.t('objects.destroy_success', :o => @generator.name)
    redirect_to :action => 'index'
  end
  
  protected
    def generator_params
      params.require(:generator).permit!
    end

    def generally_authorized?
      current_user.kind_admin? || (action_name == 'show')
    end
  
end
