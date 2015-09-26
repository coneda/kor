class TplController < ApplicationController

  skip_before_filter :locale, :maintenance, :authentication, :authorization, :legal

  layout false

  def denied
    
  end

  def pagination
    
  end

  def relation

  end

  def media_relation
    
  end

  def relationship
    
  end

end