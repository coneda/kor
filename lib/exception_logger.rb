class ExceptionLogger
  def self.log(exception, request = nil)
    ExceptionLog.create( 
      :kind => exception.class.to_s, 
      :message => exception.message,
      :backtrace => exception.backtrace.join("\r\n"),
      :params => request.parameters,
      :uri => request.request_uri
    )
  end
end
