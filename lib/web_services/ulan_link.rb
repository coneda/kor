class WebServices::UlanLink < WebServices::Link

  def self.label
    "Union List of Artist Names"
  end
  
  def self.external_reference_label
    "ULAN-ID"
  end

  def self.link_for(entity)
    id = entity.external_references[name]
    unless id.blank?
      return "http://www.getty.edu/vow/ULANFullDisplay?find=&role=&nation=&prev_page=1&subjectid=" + id
    else
      return nil
    end
  end
  
  def self.needs_external_reference?
    true
  end
  
end
