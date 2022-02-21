class KindsController < JsonController
  skip_before_action :auth, only: [:index, :show]
  skip_before_action :legal, only: [:index, :show]

  def index
    @records = Kind.all
    @records = @records.active if params.has_key?(:only_active)
    @records = @records.without_media if params.has_key?(:no_media)
    @total = @records.count
    render template: 'json/index'
  end

  def show
    @record = Kind.find(params[:id])
    render template: 'json/show'
  end

  def create
    @kind = Kind.new(kind_params)

    if @kind.save
      render_created @kind
    else
      render_422 @kind.errors
    end
  end

  def update
    @kind = Kind.find(params[:id])

    if @kind.update(kind_params)
      render_updated @kind
    else
      render_422 @kind.errors
    end
  end

  def destroy
    @kind = Kind.find(params[:id])

    # TODO: this has to deal with deleted entities
    # TODO: this should be moved to the model somehow
    if @kind.medium_kind?
      render_422 nil, I18n.t('messages.medium_kind_not_deletable')
    elsif @kind.children.present?
      render_422 nil, I18n.t('messages.kind_has_children')
    elsif @kind.entities.count > 0
      render_422 nil, I18n.t('messages.kind_has_entities')
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

    def auth
      require_kind_admin
    end
end
