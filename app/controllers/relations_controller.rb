class RelationsController < JsonController
  skip_before_action :auth, :only => ['index', 'names', 'show']

  def index
    params[:include] = param_to_array(params[:include], ids: false)
    @total = Relation.count
    @records = Relation.all
    render template: 'json/index'
  end

  def names
    @names = Relation.available_relation_names(
      from_ids: params[:from_kind_ids],
      to_ids: params[:to_kind_ids]
    )

    render :json => @names
  end

  def show
    params[:include] = param_to_array(params[:include], ids: false)
    @record = Relation.find(params[:id])
    render template: 'json/show'
  end

  def create
    @record = Relation.new(relation_params)

    if @record.save
      render_created @record
    else
      render_422 @record.errors
    end
  end

  def update
    @record = Relation.find(params[:id])

    if @record.update_attributes(relation_params)
      render_updated @record
    else
      render_422 @record.errors
    end
  end

  def destroy
    @record = Relation.find(params[:id])
    @record.destroy
    render_deleted @record
  end

  def invert
    @record = Relation.find(params[:id])

    @record.invert!
    render_200 I18n.t('objects.invert_success', o: Relation.model_name.human)
  end

  def merge
    @record = Relation.find(params[:id])
    @others = Relation.find_by!(id: params[:other_id])

    if @record.can_merge?(@others)
      if params[:check_only]
        render_200 I18n.t('objects.could_merge', o: Relation.model_name.human(count: :other))
      else
        @record.merge!(@others)
        render_200 I18n.t('objects.merge_success', o: Relation.model_name.human(count: :other))
      end
    else
      render_422 nil, I18n.t('errors.relations_merge_failure')
    end
  end

  protected

    def relation_params
      params.require(:relation).permit!
    end

    def auth
      require_relation_admin
    end
  
end
