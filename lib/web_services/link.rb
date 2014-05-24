class WebServices::Link

  def self.label
    to_s.camelize.split('::').last.gsub('Link','')
  end
  
  def self.external_reference_label
    label
  end
  
  def self.needs_external_reference?
    false
  end
  
  def self.external_reference
    name
  end
  
  def self.to_sym
    to_s.gsub("WebServices::", "").gsub("Link", "").underscore.to_sym
  end
  
  def self.name
    self.to_sym.to_s
  end
  
  def self.multiple?
    false
  end
  
end
