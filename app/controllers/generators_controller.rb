class GeneratorsController < JsonController
  before_filter do
    @kind = Kind.find(params[:kind_id])
    @generators = @kind.generators
  end
  
  def show
    @record = @generators.find(params[:id])
    render template: 'json/show'
  end

  def create
    @record = @generators.build(generator_params)
    @record.kind_id = params[:kind_id]

    if @record.save
      render_created @record
    else
      render_422 @record.errors
    end
  end

  def update
    @record = @generators.find(params[:id])

    if @record.update_attributes(generator_params)
      render_updated @record
    else
      render_422 @record.errors
    end
  end

  def destroy
    @record = @generators.find(params[:id])
    @record.destroy
    render_deleted @record
  end

  protected

    def generator_params
      params.fetch(:generator, {}).permit(:name, :directive)
    end

    def auth
      if ['update', 'create', 'destroy'].include?(action_name)
        require_kind_admin
      end
    end
  
end
