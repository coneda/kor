class FieldsController < JsonController

  before_filter do
    params[:klass] ||= 'Fields::String'
  
    @kind = Kind.find(params[:kind_id])
    @fields = @kind.fields
  end
  
  def show
    @field = @fields.find(params[:id])
  end

  def types
    @types = Kind.available_fields
  end

  def create
    @klass = sanitize_field_class(params[:klass])
    @field = (@klass ?
      @klass.constantize.new(field_params) : 
      Field.new(field_params)
    )
    @field.kind_id = params[:kind_id]

    if @field.save
      render_200 I18n.t('objects.create_success', o: @field.name)
    else
      render_406 @field.errors
    end
  end

  def update
    @field = @fields.find(params[:id])

    if @field.update_attributes(field_params)
      render_200 I18n.t('objects.update_success', o: @field.name)
    else
      render_406 @field.errors
    end
  end

  def destroy
    @field = @fields.find(params[:id])
    @field.destroy
    render_200 I18n.t('objects.destroy_success', o: @field.name)
  end


  protected

    def field_params
      params.fetch(:field, {}).permit(
        :kind_id, :name, :search_label, :form_label, :show_label, :lock_version,
        :show_on_entity, :is_identifier, :regex, :type
      )
    end

    def auth
      if ['update', 'create', 'destroy'].include?(action_name)
        require_kind_admin
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
