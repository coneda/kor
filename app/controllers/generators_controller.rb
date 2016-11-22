class GeneratorsController < ApplicationController

  skip_before_filter :authentication, :authorization, only: ['types', 'index']

  before_filter do
    @kind = Kind.find(params[:kind_id])
    @generators = @kind.generators
  end
  
  def index
    
  end

  def update
    @generator = @generators.find(params[:id])

    if @generator.update_attributes(generator_params)
      @message = I18n.t('objects.update_success', :o => @generator.name)
      render :action => 'save'
    else
      render :action => 'save', status: 406
    end
  end
  
  def create
    @generator = @generators.new(generator_params)
    
    if @generator.save
      @message =  I18n.t('objects.create_success', :o => @generator.name)
      render :action => 'save'
    else
      render :action => 'save', status: 406
    end
  end
  
  def destroy
    @generator = @generators.find(params[:id])
    @generator.destroy
    @message = I18n.t('objects.destroy_success', :o => @generator.name)
    render :action => 'save'
  end
  
  protected
    def generator_params
      params.fetch(:generator, {}).permit!
    end

    def generally_authorized?
      current_user.kind_admin? || (action_name == 'show')
    end
  
end
