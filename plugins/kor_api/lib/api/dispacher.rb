class Api::Dispacher

  def self.request(options = {})  
    handler_string = "::Api::Handlers::" + (options[:api_section].to_s + '_handler').classify
    
    handler = nil
    begin
      handler = handler_string.constantize.new
    rescue NameError => e
      return Api::Response.new nil, :status => 400
    end
    
    handler.handle(options[:api_action], options)
  end
  
end
