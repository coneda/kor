class RelationshipsController < ApplicationController

  layout 'normal_small'
  skip_before_filter :legal, :authentication, :authorization, :only => [:index]

  def create
    @relationship = Relationship.new(relationship_params)

    if authorized_for_relationship? @relationship, :create
      if @relationship.save
        render :json => {
          "message" => I18n.t('objects.create_success', :o => I18n.t('nouns.relationship', :count => 1) )
        }
      else
        render json: @relationship.errors, status: 406
      end
    else
      render :nothing => true, :status => 403
    end
  end

  def update
    @relationship = Relationship.find(params[:id])
    
    unless authorized_for_relationship? @relationship, :edit
      render :nothing => true, :status => 403
    else
      if @relationship.update_attributes(relationship_params)
        render :json => {
          "message" => I18n.t('objects.update_success', :o => I18n.t('nouns.relationship', :count => 1) )
        }
      else
        render json: @relationship.errors, status: 406
      end
    end
  rescue ActiveRecord::StaleObjectError
    flash[:error] = I18n.t('activerecord.errors.messages.stale_relationship_update')
    render :action => 'edit'
  end

  def destroy
    @relationship = Relationship.find(params[:id])

    if authorized_for_relationship? @relationship, :delete
      @relationship.destroy
      render :json => {
        "message" => I18n.t('objects.destroy_success', :o => I18n.t('nouns.relationship', :count => 1) )
      }
    else
      render :nothing => true, :status => 403
    end
  end


  protected

    def relationship_params
      params.require(:relationship).permit(
        :from_id, :to_id, :relation_id, :relation_name, properties: []
      ).tap do |w|
        w[:properties] = params[:relationship][:properties]
      end
    end

end
