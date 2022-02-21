class Iiif::MediaController < JsonController
  layout false

  def index
    if params[:id].present?
      @entity = Entity.only_kinds(Kind.medium_kind.id).find(params[:id])
    end

    # we don't care about permissions here because its up to the custom template
    # to make sure the right data is exposed

    alt = Kor.settings['mirador_page_template']
    if alt.present? && File.exist?(alt)
      render inline: File.read(alt)
    end
  end

  def show
    @entity = Entity.only_kinds(Kind.medium_kind.id).find(params[:id])

    if allowed_to?(:view, @entity.collection)
      dimensions = `identify -format '%wx%h' #{@entity.medium.path(:normal)}`
      @width, @height = dimensions.split('x').map{ |v| v.to_i }
      dimensions = `identify -format '%wx%h' #{@entity.medium.path(:thumbnail)}`
      @thumb_width, @thumb_height = dimensions.split('x').map{ |v| v.to_i }

      alt = Kor.settings['mirador_manifest_template']
      if alt.present? && File.exist?(alt)
        render inline: File.read(alt), type: :jbuilder
      end
    else
      render_403
    end
  end
end
