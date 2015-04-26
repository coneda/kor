class Api::OaiPmh::EntitiesController < Api::OaiPmh::BaseController

  protected

    def records
      Entity.
        allowed(current_user, :view).
        includes(:kind, :medium, :datings, :taggings)
    end

    def base_url
      api_oai_pmh_entities_url
    end

    def earliest_timestamp
      model = records.order(:created_at).first
      model ? model.created_at : super
    end

end