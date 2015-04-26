class Api::OaiPmh::RelationshipsController < Api::OaiPmh::BaseController

  protected

    def records
      Relationship.
        allowed(current_user, :view).
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