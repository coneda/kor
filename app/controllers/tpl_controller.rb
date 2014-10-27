class TplController < ApplicationController

  skip_before_filter :locale, :maintenance, :authentication, :authorization, :legal

  layout false

  def denied
    
  end

end