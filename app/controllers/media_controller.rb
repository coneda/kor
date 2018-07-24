class MediaController < ApplicationController

  skip_before_filter :authorization

  def view
    @medium = Medium.find params[:id]

    if authorized?(:view, @medium.entity.collection)
      render :layout => 'wide'
    else
      # TODO: should be handled with riot
      render_403
    end
  end

  def show
    id = params[:id] || (params[:id_part_01] + params[:id_part_02] + params[:id_part_03]).to_i
    @medium = Medium.includes(:entity => :collection).find(id)

    style = param_to_style(params[:style])
    auth = if style == :original
      authorized?(:download_originals, @medium.entity.collection) || (
        !@medium.content_type.match(/\image/) && 
        authorized?(:view, @medium.entity.collection)
      )
    else
      ref = request.referrer || ''
      authorized?(:view, @medium.entity.collection) || (
        ref.match('^' + root_url) &&
        Publishment.find_by(uuid: ref.split('/').last)
      )
    end

    if auth
      send_data @medium.data(style),
        :type => @medium.content_type(style),
        :disposition => 'inline',
        :filename => @medium.download_filename(style)
    else
      render nothing: true, status: 403
    end
  end

  def download
    @medium = Medium.find params[:id]

    style = param_to_style(params[:style])
    auth = if style == :original
      authorized?(:download_originals, @medium.entity.collection) || (
        !@medium.content_type.match(/\image/) && 
        authorized?(:view, @medium.entity.collection)
      )
    else
      authorized? :view, @medium.entity.collection
    end

    if auth
      send_data @medium.data(style),
        :type => @medium.content_type(style),
        :disposition => 'attachment',
        :filename => @medium.download_filename(style)
    else
      # TODO: test this, should be json
      render nothing: true, status: 403
    end
  end

  def transform
    @medium = Medium.find params[:id]

    if authorized?(:edit, @medium.entity.collection)
      Kor::Media.transform(@medium,
        Kor::Media.transformation_by_name(params[:transformation]),
        :operation => param_to_operation(params[:operation])
      )

      redirect_to web_path(:anchor => entity_path(@medium.entity))
    else
      # TODO: test this, should probably be handled as json
      render nothing: true, status: 403
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

end
