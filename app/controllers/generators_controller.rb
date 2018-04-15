class GeneratorsController < JsonController

  before_filter do
    @kind = Kind.find(params[:kind_id])
    @generators = @kind.generators
  end
  
  def show
    @generator = @generators.find(params[:id])
  end

  def create
    @generator = @generators.build(generator_params)
    @generator.kind_id = params[:kind_id]

    if @generator.save
      render_200 I18n.t('objects.create_success', o: @generator.name)
    else
      render_406 @generator.errors
    end
  end

  def update
    @generator = @generators.find(params[:id])

    if @generator.update_attributes(generator_params)
      render_200 I18n.t('objects.update_success', o: @generator.name)
    else
      render_406 @generator.errors
    end
  end

  def destroy
    @generator = @generators.find(params[:id])
    @generator.destroy
    render_200 I18n.t('objects.destroy_success', o: @generator.name)
  end

  protected
    def generator_params
      params.fetch(:generator, {}).permit(:name, :directive)
    end

    def generally_authorized?
      if ['update', 'create', 'destroy'].include?(action_name)
        current_user.kind_admin?
      else
        true
      end
    end
  
end
