class Api::Response
  attr_reader :data, :content_type, :status

  def initialize(data, options = {})
    @data = data
  
    @renderer = options[:renderer] || Api::Renderers::Base
    @content_type = options[:content_type] || 'text/xml'
    @render_options = options[:render_options] || {}
    @status = options[:status] || 200
  end
  
  def render
    @renderer.new.render @data, @render_options
  end
  
end
