class Fields::Isbn < Field

  serialize :settings

  def validate_value
    unless value.blank?
      add_error :invalid unless value.gsub('-', '').match /^(978|979)?[0-9]{9}[0-9x]?$/
    end
  end
  
  def self.label
    'ISBN'
  end
  
  def index?
    true
  end
  
end
