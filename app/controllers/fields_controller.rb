class FieldsController < ApplicationController

  layout 'small_normal'

  before_filter do
    params[:klass] ||= 'Fields::String'
  
    @kind = Kind.find(params[:kind_id])
    @fields = @kind.fields
  end
  
  def index
    
  end

  def new
    @field = params[:klass].constantize.new(params[:field])
    @form_url = kind_fields_path(@kind)
  end
  
  def edit
    @field = Field.find(params[:id])
    @form_url = kind_field_path(@kind, @field)
  end
  
  def update
    @field = Field.find(params[:id])
    @form_url = kind_field_path(@kind, @field)
    
    if @field.update_attributes params[:field]
      flash[:notice] = I18n.t('objects.update_success', :o => @field.show_label)
      redirect_to :action => 'index'
    else
      render :action => 'edit'
    end
  end
  
  def create
    @field = params[:klass].constantize.new(params[:field])
    @form_url = kind_fields_path(@kind)
    
    if @field.save
      flash[:notice] = I18n.t('objects.create_success', :o => @field.show_label)
      redirect_to :action => 'index'
    else
      render :action => 'new'
    end
  end
  
  def destroy
    @field = @fields.find(params[:id])
    @field.destroy
    flash[:notice] = I18n.t('objects.destroy_success', :o => @field.show_label)
    redirect_to :action => 'index'
  end
  
  def edit_schema
    @kind = Kind.find(params[:id])
    @schema = @kind.schema
    render :layout => 'small_normal'
  end
  
  def drop_schema_field
    @kind = Kind.find(params[:id])
    @kind.fields = @kind.schema.reject do |f|
      f.name == params[:name]
    end
    
    if @kind.save
      render :nothing => true
    else
      render :nothing => true, :status => :unacceptable
    end
  end

  protected
    def generally_authorized?
      current_user.kind_admin?
    end
end
