class Api::Iiif::MediaController < BaseController

  layout false

  def index

  end

  def show
    @entity = Kind.medium_kind.entities.find(params[:id])
    dimensions = `identify -format '%wx%h' #{@entity.medium.path(:normal)}`
    @width, @height = dimensions.split('x').map{|v| v.to_i}
    dimensions = `identify -format '%wx%h' #{@entity.medium.path(:thumbnail)}`
    @thumb_width, @thumb_height = dimensions.split('x').map{|v| v.to_i}
  end

end