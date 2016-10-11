class FieldsController < ApplicationController

  layout 'small_normal'

  before_filter do
    params[:klass] ||= 'Fields::String'
  
    @kind = Kind.find(params[:kind_id])
    @fields = @kind.fields
  end
  
  def index
    
  end

  def types
    @types = Kind.available_fields
  end

  def new
    @field = sanitize_field_class(params[:klass]).constantize.new(field_params)
    @form_url = kind_fields_path(@kind)
  end
  
  def edit
    @field = Field.find(params[:id])
    @form_url = kind_field_path(@kind, @field)
  end
  
  def update
    @field = Field.find(params[:id])
    @form_url = kind_field_path(@kind, @field)
    
    if @field.update_attributes field_params
      flash[:notice] = I18n.t('objects.update_success', :o => @field.show_label)
      redirect_to :action => 'index'
    else
      render :action => 'edit'
    end
  end
  
  def create
    @field = sanitize_field_class(params[:klass]).constantize.new(field_params)
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
  

  protected

    def field_params
      params.fetch(:field, {}).permit(
        :kind_id, :name, :search_label, :form_label, :show_label, :lock_version,
        :show_on_entity, :type, :is_identifier
      )
    end

    def generally_authorized?
      current_user.kind_admin?
    end

    def sanitize_field_class(str)
      if Kind.available_fields.map{|klass| klass.name}.include?(str)
        str
      end
    end
end
