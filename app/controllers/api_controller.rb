class ApiController < ApplicationController

  protected

    def render_message(message, status)
      @message = message
      render status: status, action: 'message'
    end

    def render_403(message)
      render_message message, 403
    end

    def render_404(message)
      render_message message, 404
    end

    def render_200(message)
      render_message message, 200
    end

    def browser_path(path = '')
      "#{root_path}##{path}"
    end

end