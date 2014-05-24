require 'rack/utils'

class FlashSession
  def initialize(app, session_key = '_session_id')
    @app = app
    @session_key = session_key
  end

  def call(env)
    env.each do |k, v|
      if v.is_a?(String) && v.match(/54df8d458be5a0faa4f2f0d650df03d2/)
        puts "#{k}: #{v.inspect}"
      end
    end
    
    if env['HTTP_USER_AGENT'] =~ /^(Adobe|Shockwave) Flash/
      params = Rack::Request.new(env).params
      
      # Re-establish the session from the key given in params
      unless params['flash_session_id'].nil?
        env['HTTP_COOKIE'] = "#{@session_key}=#{params['flash_session_id']}".freeze
      end
      
      # Establish the (action) content type from the accept header given in params
      unless params['http_accept_header'].nil?
        env['HTTP_ACCEPT'] = params['http_accept_header'].freeze
      end
    end
    
    @app.call(env)
  end
end
