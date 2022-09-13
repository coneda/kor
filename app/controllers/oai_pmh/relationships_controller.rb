class OaiPmh::RelationshipsController < OaiPmh::BaseController
  def get_record
    @record = locate(params[:identifier])

    if @record
      if current_user.allowed_to?(:view, [@record.from.collection, @record.to.collection])
        render template: "oai_pmh/get_record"
      else
        head 403
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
    end

    def base_url
      oai_pmh_relationships_url
    end

    def earliest_timestamp
      model = records.order(:created_at).first
      model ? model.created_at : super
    end
end
