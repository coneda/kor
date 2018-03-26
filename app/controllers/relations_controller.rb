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


  protected

    def relation_params
      params.require(:relation).permit!
    end

    def generally_authorized?
      if ['names', 'index'].include?(params[:action])
        true
      else
        current_user.relation_admin?
      end
    end
  
end
