class RelationshipsController < ApplicationController

  layout 'normal_small'
  skip_before_filter :legal, :authentication, :authorization, :only => [:index]

  def index
    respond_to do |format|
      format.json do
        if user = (current_user || User.guest)
          scope = Relationship.
            paginate(params[:page], params[:per_page]).
            as_user(user).
            from_ids(params[:from_ids]).
            to_ids(params[:to_ids]).
            from_kind_ids(params[:from_kind_ids]).
            to_kind_ids(params[:to_kind_ids]).
            via(params[:relation_names]).
            with_ends

          # puts scope.to_sql

          render :json => scope.as_json(:root => false)
        else
          render :nothing => true, :status => 401
        end
      end
    end
  end

  def show
    @relationship = Relationship.find(params[:id])

    respond_to do |format|
      format.json do
        if authorized_for_relationship? @relationship
          render :json => @relationship.to_json(:root => false)
        else
          render :nothing => true, :status => 403
        end
      end
    end
  end

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
        redirect_to web_path(:anchor => entity_path(@relationship.from))
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
      success = @relationship.update_attributes(params[:relationship])

      respond_to do |format|
        format.html do
          if success
            flash[:notice] = I18n.t('objects.update_success', :o => I18n.t('nouns.relationship', :count => 1) )
            redirect_to web_path(:anchor => entity_path(@relationship.from))
          else
            render :action => "edit"
          end
        end
        format.json do
          if success
            render :json => @relationship.to_json(:root => false)
          else
            render :nothing => true, :status => 406
          end
        end
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
      redirect_to back_save
    end

  end

end
