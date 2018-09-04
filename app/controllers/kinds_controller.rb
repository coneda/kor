# TODO: remove non-json responses
class KindsController < ApplicationController

  skip_before_filter :authentication, :authorization, only: ['index', 'show']

  def index
    params[:include] = param_to_array(params[:include], ids: false)

    @kinds = Kind.all
    @kinds = @kinds.active if params.has_key?(:only_active)

    respond_to do |format|
      format.html {render :layout => 'wide'}
      format.json
    end
  end

  def show
    params[:include] = param_to_array(params[:include], ids: false)
    
    @kind = Kind.find(params[:id])
  end

  def create
    @kind = Kind.new(kind_params)

    if @kind.save
      @messages << I18n.t( 'objects.create_success', :o => Kind.model_name.human )
      render action: 'save'
    else
      @messages << I18n.t('activerecord.errors.template.header')
      render action: 'save', status: 406
    end
  end

  def update
    @kind = Kind.find(params[:id])

    if @kind.update_attributes(kind_params)
      @messages << I18n.t('objects.update_success', o: Kind.model_name.human)
      render action: 'save'
    else
      @messages << I18n.t('activerecord.errors.template.header')
      render action: 'save', status: 406
    end
  rescue ActiveRecord::StaleObjectError => e
    @messages << I18n.t('activerecord.errors.messages.stale_kind_update')
    render action: 'save', status: 406
  end

  def destroy
    @kind = Kind.find(params[:id])
    
    if @kind.medium_kind?
      @messages << I18n.t('errors.medium_kind_not_deletable')
      render action: 'save', status: 406
    elsif @kind.children.present?
      @messages << I18n.t('errors.kind_has_children')
      render action: 'save', status: 406
    elsif @kind.entities.count > 0
      @messages << I18n.t('errors.kind_has_entities')
      render action: 'save', status: 406
    else
      @kind.destroy
      @messages << I18n.t('objects.destroy_success', :o => Kind.model_name.human)
      render action: 'save'
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

    def generally_authorized?
      current_user.kind_admin?
    end

end
