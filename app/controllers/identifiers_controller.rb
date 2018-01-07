class IdentifiersController < ApplicationController

  skip_before_filter :authentication, :authorization, :legal

  def resolve
    entity = Identifier.resolve!(params[:id], params[:kind])

    respond_to do |format|
      format.html do
        redirect_to web_path(:anchor => entity_path(entity))
      end
      format.json do
        render json: {id: entity.id}
      end
    end
  end

end