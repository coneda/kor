class IdentifiersController < JsonController

  skip_before_filter :auth, :legal

  def resolve
    entity = Identifier.resolve!(params[:id], params[:kind])

    respond_to do |format|
      format.html do
        redirect_to root_path(:anchor => "/entities/#{entity.id}")
      end
      format.json do
        redirect_to entity
      end
    end
  end

end