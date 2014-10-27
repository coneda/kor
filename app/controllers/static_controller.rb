class StaticController < ApplicationController
  skip_before_filter [ :authentication, :maintenance ], :except => :help
  
  layout 'wide'
  
  def under_maintenance
    # this is for getting back to the login when the user presses f5
    if Kor.under_maintenance?
      render
    else
      flash[:notice] = I18n.t('notices.maintenance_done')
      redirect_to root_url
    end
  end

  def legal
  end

  # TODO: rename the contact.txt to about.txt  
  def about
  end
  
  def error
  end
  
  def help
  end
  
  def blaze
    flash.keep
    render :layout => 'blaze', :nothing => true
  end
  
end
