class WebServices::Dispacher

  def self.web_services
    Dir.glob('lib/web_services/*_link.rb').map do |f|
      ("WebServices::" + File.basename(f).gsub(".rb", '').classify).constantize
    end
  end
  
  def self.web_service_from_name(name)
    web_services.find do |ws|
      ws.name == name.to_s
    end
  end
  
  def self.label_for_name(name)
    web_service_from_name(name).external_reference_label
  end
  
  def self.web_services_for_kind(kind)
    (kind.web_services || []).map do |ws|
      web_service_from_name(ws)
    end
  end
  
  def self.web_services_for_kind_with_external_reference(kind)
    web_services_for_kind(kind).select{|ws| ws.needs_external_reference?}
  end
  
  def self.links_for(entity)
    web_services_for_kind(entity.kind).map do |ws|
      if ws.multiple?
        {:header => ws.label, :links => ws.link_for(entity)}
      else
        [ws.label, ws.link_for(entity)]
      end
    end
  end
  
end
