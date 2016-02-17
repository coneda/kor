class DirectedRelationshipsController < ApplicationController

  skip_before_action :legal, :authentication, :authorization, :only => [:index]

  def index
    if user = (current_user || User.guest)
      @directed_relationships = DirectedRelationship.
        by_entity(params[:entity_id]).
        by_relation_name(params[:relation_name]).
        allowed(user, :view).
        pageit(params[:page], params[:per_page])
    else
      render :nothing => true, :status => 401
    end
  end

  def show
    @directed_relationship = DirectedRelationship.find(params[:id])

    unless authorized_for_relationship? @directed_relationship
      render :nothing => true, :status => 403
    end
  end

end