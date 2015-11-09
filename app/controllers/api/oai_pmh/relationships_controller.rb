class Api::OaiPmh::RelationshipsController < Api::OaiPmh::BaseController

  def get_record
    @record = locate(params[:identifier])

    if current_user.allowed_to?(:view, [@record.from.collection, @record.to.collection])
      render :template => "api/oai_pmh/get_record"
    else
      render :nothing => true, :status => 403
    end
  end

  protected

    def records
      Relationship.
        includes(:from, :to, :relation)
    end

    def base_url
      api_oai_pmh_relationships_url
    end

    def earliest_timestamp
      model = records.order(:created_at).first
      model ? model.created_at : super
    end

end