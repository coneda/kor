require 'rack/utils'

class FlashSessionCookieMiddleware
  def initialize(app, session_key = 'kor_session')
    @app = app
    @session_key = session_key
  end

  def call(env)
    if env['HTTP_USER_AGENT'] =~ /^(Adobe|Shockwave) Flash/
      params = env['rack.request.form_hash']
      env['HTTP_COOKIE'] = [ @session_key, params[@session_key] ].join('=').freeze unless params[@session_key].nil?
    end
    @app.call(env)
  end
end