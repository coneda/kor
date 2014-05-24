class WebServices::WikipediaLink < WebServices::Link
  
  def self.label
    "Bei Wikipedia suchen"
  end
  
  def self.link_for(entity, options = {})
    "http://de.wikipedia.org/wiki/Spezial:Search?search=" + URI.escape(entity.name)
  end
  
end
