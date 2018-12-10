class Iiif::MediaController < JsonController
  layout false

  def index
  end

  def show
    @entity = Kind.medium_kind.entities.find(params[:id])

    if allowed_to?(:view, @entity.collection)
      dimensions = `identify -format '%wx%h' #{@entity.medium.path(:normal)}`
      @width, @height = dimensions.split('x').map { |v| v.to_i }
      dimensions = `identify -format '%wx%h' #{@entity.medium.path(:thumbnail)}`
      @thumb_width, @thumb_height = dimensions.split('x').map { |v| v.to_i }
    else
      render_403
    end
  end
end
