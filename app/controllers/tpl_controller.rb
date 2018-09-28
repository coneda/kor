class TplController < ApplicationController

  skip_before_filter :locale, :maintenance, :auth, :legal

  layout false

  def denied
    
  end

end