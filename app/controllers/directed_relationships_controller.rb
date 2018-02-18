class DirectedRelationshipsController < ApplicationController

  skip_before_action :legal, :authentication, :authorization, :only => [:index]

  def index
    params[:from_entity_id] ||= params[:entity_id]

    params[:include] = param_to_array(params[:include], ids: false)
    params[:from_entity_id] = param_to_array(params[:from_entity_id])
    params[:to_entity_id] = param_to_array(params[:to_entity_id])
    params[:relation_name] = param_to_array(params[:relation_name], ids: false)
    params[:from_kind_id] = param_to_array(params[:from_kind_id])
    params[:to_kind_id] = param_to_array(params[:to_kind_id])
    params[:except_to_kind_id] = param_to_array(params[:except_to_kind_id])

    if user = (current_user || User.guest)
      @directed_relationships = DirectedRelationship.
        order_by_name.
        by_from_entity(params[:from_entity_id]).
        by_to_entity(params[:to_entity_id]).
        by_relation_name(params[:relation_name]).
        by_from_kind(params[:from_kind_id]).
        by_to_kind(params[:to_kind_id]).
        except_to_kind(params[:except_to_kind_id]).
        allowed(user, :view)
    else
      render_403
    end
  end

  def show
    @directed_relationship = DirectedRelationship.find(params[:id])

    unless authorized_for_relationship? @directed_relationship
      render_403
    end
  end

end