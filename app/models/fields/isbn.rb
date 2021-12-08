class Fields::Isbn < Field
  def validate_value
    result = super
    return result if result != true

    if value.present? && !value.gsub('-', '').match(/^(978|979)?[0-9]{9}[0-9x]?$/)
      return :invalid
    end

    true
  end

  def self.label
    'ISBN'
  end

  def index?
    true
  end
end
