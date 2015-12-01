class ExceptionLogsController < ApplicationController
  layout 'wide'

  def index
    @exception_logs = ExceptionLog.
      order("created_at DESC").
      paginate(:page => params[:page], :per_page => 8)
  end

  def cleanup
    ExceptionLog.delete_all

    redirect_to :action => 'index'
  end
  
  protected
    def generally_authorized?
      current_user.developer?
    end
end
