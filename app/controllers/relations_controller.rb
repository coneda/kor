class RelationsController < ApplicationController
  skip_before_action :authentication, :only => [:names, :index]

  layout 'normal_small'

  def index
    @relations = if params[:entity_id]
      Entity.find(params[:entity_id]).relation_counts(current_user)
    else
      Relation.paginate(:page => params[:page], :per_page => 30)
    end

    respond_to do |format|
      format.json
      format.html do
        render layout: 'wide'
      end
    end
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
    redirect_to root_path
  end

  def new
    @relation = Relation.new
  end

  def edit
    @relation = Relation.find(params[:id])
  end

  def create
    @relation = Relation.new(relation_params)

    if @relation.save
      flash[:notice] = I18n.t( 'objects.create_success', :o => I18n.t('nouns.relation', :count => 1) )
      redirect_to relations_path
    else
      render :action => "new"
    end
  end

  def update
    params[:relation][:from_kind_ids] ||= []
    params[:relation][:to_kind_ids] ||= []
    
    @relation = Relation.find(params[:id])
    
    if @relation.update_attributes(relation_params)
      flash[:notice] = I18n.t( 'objects.update_success', :o => I18n.t('nouns.relation', :count => 1) )
      redirect_to relations_path
    else
      render :action => "edit"
    end
  rescue ActiveRecord::StaleObjectError
    flash[:error] = I18n.t('activerecord.errors.messages.stale_relation_update')
    render :action => 'edit'
  end

  def destroy
    @relation = Relation.find(params[:id])
    @relation.destroy

    flash[:notice] = I18n.t( 'objects.destroy_success', :o => I18n.t('nouns.relation', :count => 1) )
    redirect_to(relations_url)
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
