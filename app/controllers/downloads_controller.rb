class DownloadsController < JsonController
  def show
    @download = Download.find_by!(uuid: params[:uuid])

    send_data(@download.data,
      type: @download.content_type,
      filename: @download.file_name,
      disposition: 'attachment'
    )
  end
end
