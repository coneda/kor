class DownloadsController < BaseController
  
  def show
    @download = Download.find_by_uuid(params[:uuid])
    
    send_data(@download.data,
      :type => @download.content_type,
      :filename => @download.file_name,
      :disposition => 'attachment'
    )
  end
  
end
