class WebServices::SandrartArtworkLink < WebServices::Link

  def self.label
    "Sandrart Werk"
  end
  
  def self.external_reference_label
    "Sandrart Werk ID"
  end

  def self.link_for(entity)
    id = entity.external_references[name]
    id.blank? ? nil : "http://ta.sandrart.net/aw/#{id}"
  end
  
  def self.needs_external_reference?
    true
  end
  
end
