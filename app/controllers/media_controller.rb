class MediaController < JsonController
  skip_before_action :auth

  def show
    id = params[:id] || (params[:id_part_01] + params[:id_part_02] + params[:id_part_03]).to_i
    @medium = Medium.includes(:entity => :collection).find(id)

    style = param_to_style(params[:style])
    auth = if style == :original
      allowed_to?(:download_originals, @medium.entity.collection) || (
        !@medium.content_type.match(/\image/) &&
        allowed_to?(:view, @medium.entity.collection)
      )
    else
      allowed_to?(:view, @medium.entity.collection) ||
        Publishment.exists?(uuid: params[:uuid])
    end

    disposition = (params[:disposition] == 'download' ? 'attachment' : 'inline')

    if auth
      status = 200
      response.headers['Accept-Ranges'] = 'bytes'

      if range
        response.headers['Content-Range'] = "bytes #{range[0]}-#{range[1]}/#{@medium.size(style)}"
        status = 206
      end

      send_data @medium.data(style, range: range),
        type: @medium.content_type(style),
        disposition: disposition,
        filename: @medium.download_filename(style),
        status: status
    else
      render_403
    end
  end

  def transform
    @medium = Medium.find params[:id]

    if allowed_to?(:edit, @medium.entity.collection)
      Kor::Media.transform(@medium,
        Kor::Media.transformation_by_name(params[:transformation]),
        :operation => param_to_operation(params[:operation])
      )

      render_200 I18n.t('objects.transform_success', o: I18n.t('activerecord.models.medium', count: 1))
    else
      render_403
    end
  end

  protected

    def param_to_style(param)
      allowed = ["icon", "thumbnail", "preview", "screen", "normal", "original"]
      allowed.include?(param) ? param.to_sym : param
    end

    def param_to_operation(param)
      allowed = ["rotate_cw", "rotate_ccw", "rotate_180"]
      allowed.include?(param) ? param.to_sym : param
    end

    def range
      if raw = request.headers['Range']
        type, values = raw.split('=')
        if type == 'bytes'
          result = values.split('-').map{ |s| s.to_i }
          unless result[1]
            result[1] = result[0] + 1024 * 256
          end

          result
        end
      end
    end
end
