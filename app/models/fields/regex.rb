class Fields::Regex < Field

  def validate_value
    if value.present?
      if !value.match(matcher)
        return :invalid
      end
    end

    true
  end
  
  def self.label
    'regex'
  end
  
  def regex=(value)
    settings[:regex] = value
  end
  
  def regex
    if settings[:regex].blank?
      settings[:regex] = '/^.*$/'
    end

    settings[:regex]
  end

  def matcher
    ::Regexp.new(regex)
  end

  def self.fields
    [{'name' => 'regex'}]
  end
  
end
