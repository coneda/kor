# TODO: remove non-json responses
class KindsController < JsonController

  skip_before_filter :authentication, :authorization, only: [:index, :show]

  def index
    params[:include] = param_to_array(params[:include], ids: false)

    @kinds = Kind.all
    @kinds = @kinds.active if params.has_key?(:only_active)
    @kinds = @kinds.without_media if params.has_key?(:no_media)
  end

  def show
    params[:include] = param_to_array(params[:include], ids: false)
    
    @kind = Kind.find(params[:id])
  end

  def create
    @kind = Kind.new(kind_params)

    if @kind.save
      render_created @kind
    else
      render_406 @kind.errors
    end
  end

  def update
    @kind = Kind.find(params[:id])

    params[:kind] ||= {}
    params[:kind][:settings] ||= {}
    params[:kind][:settings][:tagging] ||= false

    if @kind.update_attributes(kind_params)
      render_updated @kind
    else
      render_406 @kind.errors
    end
  rescue ActiveRecord::StaleObjectError => e
    render_406 I18n.t('activerecord.errors.messages.stale_kind_update')
  end

  def destroy
    @kind = Kind.find(params[:id])
    
    if @kind.medium_kind?
      render_406 I18n.t('errors.medium_kind_not_deletable')
    elsif @kind.children.present?
      render_406 I18n.t('errors.kind_has_children')
    elsif @kind.entities.count > 0
      render_406 I18n.t('errors.kind_has_entities')
    else
      @kind.destroy
      render_200 I18n.t('objects.destroy_success', o: Kind.model_name.human)
    end
  end
  
  
  protected
    
    def kind_params
      params.require(:kind).permit(
        :schema, :name, :plural_name, :description,
        :tagging, :name_label, :dating_label, :distinct_name_label, :url,
        :abstract, parent_ids: [], child_ids: [],
      )
    end

    # TODO: replace with new mechanism
    def auth
      require_kind_admin
    end
    
end
