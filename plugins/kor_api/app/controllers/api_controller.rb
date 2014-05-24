class ApiController < ApplicationController
  skip_before_filter :before_all, :maintenance, :authentication, :authorization, :legal
  before_filter :api_auth
  
  def invoke
    @api_response ||= Api::Dispacher.request(params)
    
    if @api_response.status == 200
      if @api_response.content_type == 'text/xml'
        render :text => @api_response.render, :content_type => 'text/xml'
      else
        send_data @api_response.data, :type => @api_response.content_type, :disposition => 'inline'
      end
    else
      render :nothing => true, :status => @api_response.status
    end
  end
    
  private  
    def api_auth
      users = Kor.config['auth']['api']['users']
      section = params[:api_section]
      action = params[:api_action]
    
      authenticate_or_request_with_http_basic do |username, password|
        users = users.select do |u|
          u['username'] == username and u['password'] == password
        end
        
        ! users.empty?
      end
    
      users.select do |u|
        u['sections'] == 'all' or (u['sections'][section] and u['sections'][section].include?(action))
      end
      
      if users.empty?
        allowed_methods = []
        users.each do |u|
          u['sections'].each do |s, as|
            as.each do |a|
              allowed_methods << "#{s}/#{a}"
            end
          end
        end
        response.headers['Allow'] = allowed_methods.join(',')
        @api_reponse = Api::Response.new nil, :status => 405
        false
      else
        true
      end
    end
  
end
