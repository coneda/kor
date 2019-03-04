class FieldsController < JsonController
  def show
    @kind = Kind.find(params[:kind_id])
    @record = @kind.fields.find(params[:id])
    render template: 'json/show'
  end

  def types
    @types = Kind.available_fields
  end

  # TODO: this is messy, clean it up, the defaults don't need to be set that
  # way
  def create
    @kind = Kind.find(params[:kind_id])

    @record = @kind.fields.new(field_params)
    @record.kind = @kind

    if @record.save
      render_created @record
    else
      render_422 @record.errors
    end
  end

  def update
    @kind = Kind.find(params[:kind_id])
    @record = @kind.fields.find(params[:id])

    if @record.update_attributes(field_params)
      render_updated @record
    else
      render_422 @record.errors
    end
  end

  def destroy
    @kind = Kind.find(params[:kind_id])
    @record = @kind.fields.find(params[:id])
    @record.destroy
    render_deleted @record
  end

  protected

    def field_params
      results = params.fetch(:field, {}).permit(
        :kind_id, :name, :search_label, :form_label, :show_label, :lock_version,
        :show_on_entity, :is_identifier, :regex, :type, :values,
        :allow_other_values, :subtype
      )
      results.merge type: sanitize_type(results[:type])
    end

    def auth
      if ['update', 'create', 'destroy'].include?(action_name)
        require_kind_admin
      end
    end

    def sanitize_type(str)
      if Kind.available_fields.map { |klass| klass.name }.include?(str)
        str
      else
        'Fields::String'
      end
    end
end
