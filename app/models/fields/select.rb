class Fields::Select < Field
  def validate_value
    result = super
    return result if result != true

    # if this is not a valid case, the mandatory check in super should have
    # caught it
    return true if value.blank?

    if subtype == 'multiselect'
      value.each do |v|
        return :invalid unless value_list.include?(v)
      end
    else
      return :invalid unless value_list.include?(value)
    end

    true
  end

  def self.label
    'select'
  end

  def subtype=(v)
    settings[:subtype] = v
  end

  def subtype
    settings[:subtype] || 'select'
  end

  def values=(v)
    v = v.split("\n") unless v.is_a?(Array)
    settings[:values] = v
  end

  def values
    value_list.join("\n")
  end

  def value_list
    settings[:values] || []
  end

  def self.fields
    [
      {
        'name' => 'subtype',
        'type' => 'select',
        'options' => ['select', 'multiselect']
      }, {
        'name' => 'values',
        'type' => 'textarea'
      }
    ]
  end
end
