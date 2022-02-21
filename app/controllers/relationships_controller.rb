class RelationshipsController < JsonController
  def create
    @relationship = Relationship.new(relationship_params)

    if authorized_for_relationship?(@relationship, :create)
      if @relationship.save
        render_created @relationship
      else
        render_422 build_nested_errors(@relationship)
      end
    else
      render_403
    end
  end

  def update
    @relationship = Relationship.find(params[:id])

    if authorized_for_relationship?(@relationship, :edit)
      if @relationship.update(relationship_params)
        render_updated @relationship
      else
        render_422 build_nested_errors(@relationship)
      end
    else
      render_403
    end
  end

  def destroy
    @relationship = Relationship.find(params[:id])

    if authorized_for_relationship?(@relationship, :delete)
      @relationship.destroy
      render_deleted @relationship
    else
      render_403
    end
  end

  protected

    def relationship_params
      params.fetch(:relationship, {}).permit(
        :from_id, :to_id, :relation_id, :relation_name,
        properties: [],
        datings_attributes: [:id, :_destroy, :label, :dating_string],
      )
    end

    def build_nested_errors(relationship)
      relationship.errors.as_json.reject{ |k, _v| k.match(/^datings/) }.merge(
        'datings' => relationship.datings.map{ |d| d.errors.as_json }
      )
    end
end
