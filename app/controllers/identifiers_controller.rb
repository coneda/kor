class IdentifiersController < ApplicationController

  skip_before_filter :authentication, :authorization, :legal

  def resolve
    entity = Identifier.resolve(params[:id], params[:kind])

    if entity
      redirect_to web_path(:anchor => entity_path(entity))
    else
      render :nothing => true, :status => 403
    end
  end

end