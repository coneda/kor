class WebServices::KndLink < WebServices::Link

  def self.label
    "Gemeinsame Normdatei (GND)"
  end
  
  def self.external_reference_label
    "GND-ID"
  end

  def self.link_for(entity)
    id = entity.external_references[name]
    unless id.blank?
      return "http://d-nb.info/gnd/" + id
    else
      return nil
    end
  end
  
  def self.needs_external_reference?
    true
  end
  
end
