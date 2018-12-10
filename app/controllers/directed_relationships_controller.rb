class DirectedRelationshipsController < JsonController
  skip_before_action :legal, :auth

  def index
    if user = (current_user || User.guest)
      @records = DirectedRelationship.
        allowed(user, :view).
        order_by_name.
        by_from_entity(array_param :from_entity_id).
        by_to_entity(array_param :to_entity_id).
        by_relation_name(array_param :relation_name, ids: false).
        by_from_kind(array_param :from_kind_id).
        by_to_kind(array_param :to_kind_id).
        except_to_kind(array_param :except_to_kind_id)

      @total = @records.count
      @records = @records.pageit(page, per_page)
      render template: 'json/index'
    else
      render_403
    end
  end

  def show
    @record = DirectedRelationship.find(params[:id])

    if authorized_for_relationship? @record
      render template: 'json/show'
    else
      render_403
    end
  end
end
