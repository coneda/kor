class Api::OaiPmh::RelationshipsController < Api::OaiPmh::BaseController

  def get_record
    @record = locate(params[:identifier])

    if @record
      if current_user.allowed_to?(:view, [@record.from.collection, @record.to.collection])
        render :template => "api/oai_pmh/get_record"
      else
        render :nothing => true, :status => 403
      end
    else
      render_error 'idDoesNotExist'
    end
  end

  protected

    def records
      Relationship.
        order(:id).
        with_deleted.
        joins('LEFT JOIN relations rels ON rels.id = relationships.relation_id')
        # joins('LEFT JOIN entities froms ON froms.id = relationships.from_id').
        # joins('LEFT JOIN entities tos ON tos.id = relationships.to_id')
        # joins(
        #   :from_including_deleted,
        #   :to_including_deleted,
        #   :relation_including_deleted
        # )
    end

    def base_url
      api_oai_pmh_relationships_url
    end

    def earliest_timestamp
      model = records.order(:created_at).first
      model ? model.created_at : super
    end

end