class WebServices::ConedaInformationServiceLink < WebServices::Link

  def self.label
    "Coneda Information Service"
  end
  
  def self.external_reference_label
    "GND-ID"
  end

  def self.link_for(entity)
    id = entity.external_references[external_reference]
    unless id.blank?
      uri = "http://vault.coneda.net/api/external/pnd_beacons/#{id.strip}"
      response = HTTParty.get(uri).body
      response.blank? ? {} : ActiveSupport::JSON.decode(response)['web_links']
    else
      {}
    end
  rescue => e
    Rails.logger.error "Error caught and suppressed: #{e}"
    {}
  end
  
  def self.external_reference
    'pnd'
  end
  
  def self.needs_external_reference?
    true
  end
  
  def self.multiple?
    true
  end
  
end
