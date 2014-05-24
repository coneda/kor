class RelationshipsController < ApplicationController

  layout 'normal_small'

  def new
    @relationship = Relationship.new(params[:relationship].merge(:to_id => session[:current_entity]))
    
    if @relationship.from and @relationship.to
      unless authorized_for_relationship? @relationship, :create
        redirect_to denied_path
      end
    else
      flash[:error] = I18n.t("errors.destination_not_given")
      redirect_to back_save
    end
  end

  def edit
    @relationship = Relationship.find(params[:id])
    
    unless authorized_for_relationship? @relationship, :edit
      redirect_to denied_path
    end
  end

  def create
    @relationship = Relationship.new(params[:relationship])

    if authorized_for_relationship? @relationship, :create
      if @relationship.save
        flash[:notice] = I18n.t('objects.create_success', :o => I18n.t('nouns.relationship', :count => 1) )
        rrn = session[:recent_relation_names] || []
        rrn = rrn.unshift params[:relationship][:relation_name]
        session[:recent_relation_names] = rrn.uniq
        redirect_to @relationship.from
      else
        render :action => "new"
      end
    else
      redirect_to denied_path
    end
  end

  def update
    params[:relationship][:properties] ||= []

    @relationship = Relationship.find(params[:id])
    
    unless authorized_for_relationship? @relationship, :edit
      redirect_to denied_path
    else
      if @relationship.update_attributes(params[:relationship])
        flash[:notice] = I18n.t('objects.update_success', :o => I18n.t('nouns.relationship', :count => 1) )
        redirect_to @relationship.from
      else
        render :action => "edit"
      end
    end
  rescue ActiveRecord::StaleObjectError
    flash[:error] = I18n.t('activerecord.errors.messages.stale_relationship_update')
    render :action => 'edit'
  end

  def destroy
    @relationship = Relationship.find(params[:id])
    
    unless authorized_for_relationship? @relationship, :edit
      redirect_to denied_path
    else      
      @relationship.destroy
      redirect_to :back
    end

  end

end
