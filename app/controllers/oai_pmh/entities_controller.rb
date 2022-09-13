class OaiPmh::EntitiesController < OaiPmh::BaseController
  def get_record
    @record = locate(params[:identifier])

    if @record
      if current_user && current_user.allowed_to?(:view, @record.collection)
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
      Entity.
        order(:id).
        with_deleted.
        includes(:kind, :medium, :datings, :taggings)
    end

    def base_url
      oai_pmh_entities_url
    end

    def earliest_timestamp
      model = records.order(:created_at).first
      model ? model.created_at : super
    end
end
