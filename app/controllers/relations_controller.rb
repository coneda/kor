class RelationsController < ApplicationController
  layout 'normal_small'

  def index
    @relations = Relation.paginate :page => params[:page], :per_page => 30
    render :layout => 'wide'
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
    @relation = Relation.new(params[:relation])

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
    
    if @relation.update_attributes(params[:relation])
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
    def generally_authorized?
      current_user.relation_admin?
    end
  
end
