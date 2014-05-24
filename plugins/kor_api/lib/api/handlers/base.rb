class Api::Handlers::Base

  def actions
    []
  end

  def handle(action, options = {})
    if actions.include? action
      send(action, options)
    else
      respond nil, :status => 400
    end
  end
  
  def respond(data, options = {})
    options[:status] ||= 404 if data.blank?
    Api::Response.new(data, options)
  end
  
end
