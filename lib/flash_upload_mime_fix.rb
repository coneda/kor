class FlashUploadMimeFix
  
  def initialize(app)
    @app = app
  end
  
  def call(env)
    if hash = env['rack.request.form_hash']
      if entity = hash['entity']
        if ma = entity['medium_attributes']
          if doc = ma['document']
            mime_type = MIME::Types.type_for(doc[:filename])
            if mime_type.first
              doc[:type] = mime_type.first.content_type.to_s 
              doc[:head].gsub!("application/octet-stream", mime_type.first.content_type.to_s)
            end
          end
        end
      end
    end
    
    @app.call(env)
  end
  
end
