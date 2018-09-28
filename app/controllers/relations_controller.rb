class RelationsController < JsonController
  skip_before_action :authentication, :only => [:names, :index]

  def index
    params[:include] = param_to_array(params[:include], ids: false)
    @records = Relation.all
  end

  def names
    @names = Relation.available_relation_names(
      from_ids: params[:from_kind_ids],
      to_ids: params[:to_kind_ids]
    )

    respond_to do |format|
      format.json {render :json => @names}
    end
  end

  def show
    params[:include] = param_to_array(params[:include], ids: false)
    @relation = Relation.find(params[:id])
  end

  def create
    @relation = Relation.new(relation_params)

    if @relation.save
      render_200 I18n.t('objects.create_success', o: @relation.name)
    else
      render_406 @relation.errors
    end
  end

  def update
    @relation = Relation.find(params[:id])

    if @relation.update_attributes(relation_params)
      render_200 I18n.t('objects.update_success', o: @relation.name)
    else
      render_406 @relation.errors
    end
  rescue ActiveRecord::StaleObjectError => e
    # TODO
    # @messages << I18n.t('activerecord.errors.messages.stale_relation_update')
    # render action: 'save', status: 406
  end

  def destroy
    @relation = Relation.find(params[:id])
    @relation.destroy

    render_200 I18n.t('objects.destroy_success', o: @relation.name)
  end

  def invert
    @relation = Relation.find(params[:id])

    @relation.invert!
    @messages << I18n.t('objects.invert_success', o: Relation.model_name.human)
    render action: 'save'
  end

  def merge
    @relation = Relation.find(params[:id])
    @others = Relation.find_by!(id: params[:other_id])

    if @relation.can_merge?(@others)
      if params[:check_only]
        @messages << I18n.t('objects.could_merge', o: Relation.model_name.human(count: :other))
      else
        @relation.merge!(@others)
        @messages << I18n.t('objects.merge_success', o: Relation.model_name.human(count: :other))
      end

      render action: 'save'
    else
      @messages << I18n.t('errors.relations_merge_failure')
      render action: 'save', status: 406
    end
  end


  protected

    def relation_params
      params.require(:relation).permit!
    end

    def kind
      unless ['names', 'index'].include?(params[:action])
        require_relation_admin
      end
    end
  
end
