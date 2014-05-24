class Api::Handlers::KorHandler < Api::Handlers::Base

  def actions
    [ 'entity', 'media', 'media_checksum' ]
  end

  protected
    def entity(options)
      options.reverse_merge!(:magnitude => 'simple')
    
      identifiers = options[:identifiers].to_s.split(',')
      entities = Entity.find_all_by_uuid_keep_order(identifiers)
      
      ro = {}
      if options[:magnitude] == 'simple'
        ro[:dataset] = true
      elsif options[:magnitude] == 'extended'
          ro[:dataset] = true
          ro[:properties] = true
          ro[:synonyms] = true
          ro[:datings] = true
      elsif options[:magnitude] == 'full'
        ro[:dataset] = true
        ro[:properties] = true
        ro[:synonyms] = true
        ro[:datings] = true
        ro[:external_references] = true
        ro[:relationships] = true
      end
      
      respond entities, :render_options => ro
    end
  
    def media(options)
      medium = Kind.medium_kind.entities.find_by_uuid(options[:identifier])
      if medium
        respond medium.medium.data(:normal), :content_type => 'image/jpeg'
      else
        respond nil
      end
    end
    
    def media_checksum(options)
      identifiers = options[:identifiers].split(",")
      media = Kind.medium_kind.entities.find_all_by_uuid_keep_order(identifiers)
      respond media, :renderer => Api::Renderers::ChecksumRenderer
    end

end
