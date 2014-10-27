class MediaController < ApplicationController

  def view
    @medium = Medium.find params[:id]

    if authorized?(:view, @medium.entity.collection)
      render :layout => 'wide'
    else
      redirect_to denied_path
    end
  end

  def show
    id = params[:id] || (params[:id_part_01] + params[:id_part_02] + params[:id_part_03]).to_i
    @medium = Medium.includes(:entity => :collection).find(id)

    if authorized?(:view, @medium.entity.collection)
      style = params[:style].to_sym

      send_data @medium.data(style),
        :type => @medium.content_type(style),
        :disposition => 'inline',
        :filename => @medium.download_filename(style)
    else
      redirect_to denied_path
    end
  end

  def download
    @medium = Medium.find params[:id]

    auth = case params[:style].to_sym
      when :original
        authorized?(:download_originals, @medium.entity.collection) || (!@medium.content_type.match(/\image/) && authorized?(:view, @medium.entity.collection))
      else
        authorized?(:view, @medium.entity.collection)
    end

    if auth
      style = params[:style].to_sym

      send_data @medium.data(style),
        :type => @medium.content_type(style),
        :disposition => 'attachment',
        :filename => @medium.download_filename(style)
    else
      redirect_to denied_path
    end
  end

  def dummy
    content_type = "#{params['content_type_group']}/#{params['content_type']}"
    redirect_to Medium.dummy_path(content_type)
#    send_data Medium.dummy_data(content_type),
#      :type => 'image/png',
#      :disposition => 'inline'
  end

  def transform
    @medium = Medium.find params[:id]

    if authorized?(:edit, @medium.entity.collection)
      Media.transform(@medium,
        Media.transformation_by_name(params[:transformation]),
        :operation => params[:operation].to_sym
      )

      redirect_to web_path(:anchor => entity_path(@medium.entity))
    else
      redirect_to denied_path
    end
  end

end
