class Api::EntitiesController < Api::ApiController

  before_filter :reset_blaze

  def relationships
    params[:page] ||= 0
    params[:limit] ||= 10

    flash.keep
    render :json => {
      :relationships => blaze.relationships_for(
        current_entity,
        :name => params[:name],
        :media => params[:media],
        :offset => params[:page].to_i * params[:limit].to_i,
        :limit => params[:limit].to_i
      )
    }
  end
  
  protected

    def require_user?
      false
    end

    def current_entity
      @entity ||= Entity.find(params[:id])
    end

    def blaze
      @blaze ||= Kor::Blaze.new(current_user)
    end

    def reset_blaze
      @blaze = nil
    end

    def authorized?
      true
    end

    def allowed_to?(policy = :view, collections = Collection.all, options = {})
      options.reverse_merge!(:required => :any)
      ::Kor::Auth.authorized? current_user, policy, collections, options
    end
  
end
