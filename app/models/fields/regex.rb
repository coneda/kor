class Fields::Regex < Field

  def validate_value
    unless value.blank?
      add_error :invalid unless value.match regex
    end
  end
  
  def self.label
    'Regex'
  end
  
  def regex=(value)
    settings[:regex] = value
  end
  
  def regex
    Regexp.new(settings[:regex] ||= '')
  end
  
end
