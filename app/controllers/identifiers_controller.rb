class IdentifiersController < ApplicationController

  skip_before_filter :authentication, :authorization, :legal

  def resolve
    entity = Identifier.resolve(params[:id], params[:kind])

    respond_to do |format|
      format.html do
        if entity
          redirect_to web_path(:anchor => entity_path(entity))
        else
          render :nothing => true, :status => 403
        end
      end
      format.json do
        if entity
          render json: {id: entity.id}
        else
          render json: {message: 'not found'}, status: 401
        end
      end
    end
  end

end