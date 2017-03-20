class FieldsController < ApplicationController

  skip_before_filter :authentication, :authorization, only: ['types', 'index']

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

  def update
    @field = Field.find(params[:id])

    if @field.update_attributes(field_params)
      @messages << I18n.t('objects.update_success', o: @field.show_label)
      render action: 'save'
    else
      render action: 'save', status: 406
    end
  end
  
  def create
    @klass = sanitize_field_class(params[:klass])
    @field = (@klass ?
      @klass.constantize.new(field_params) : 
      Field.new(field_params)
    )
    @field.kind_id = params[:kind_id]

    if @field.save
      @messages << I18n.t('objects.create_success', o: @field.show_label)
      render action: 'save'
    else
      render action: 'save', status: 406
    end
  end
  
  def destroy
    @field = @fields.find(params[:id])
    @field.destroy
    @messages << flash[:notice] = I18n.t('objects.destroy_success', o: @field.show_label)
    render action: 'save'
  end
  

  protected

    def field_params
      params.fetch(:field, {}).permit(
        :kind_id, :name, :search_label, :form_label, :show_label, :lock_version,
        :show_on_entity, :is_identifier, :regex, :type
      )
    end

    def generally_authorized?
      if ['update', 'create', 'destroy'].include?(action_name)
        current_user.kind_admin?
      else
        true
      end
    end

    def sanitize_field_class(str)
      if Kind.available_fields.map{|klass| klass.name}.include?(str)
        str
      else
        'Fields::String'
      end
    end
end
