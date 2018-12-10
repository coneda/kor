class OaiPmh::KindsController < OaiPmh::BaseController
  def get_record
    @record = locate(params[:identifier])

    if @record
      render :template => "oai_pmh/get_record"
    else
      render_error 'idDoesNotExist'
    end
  end

  protected

    def records
      Kind.with_deleted
    end

    def base_url
      oai_pmh_kinds_url
    end

    def earliest_timestamp
      model = records.order(:created_at).first
      model ? model.created_at : super
    end
end
