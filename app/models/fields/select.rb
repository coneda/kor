class Fields::Select < Field
  def validate_value
    if subtype == 'multiselect'
      value.each do |v|
        return :invalid unless values.include?(v)
      end
    else
      return :invalid unless values.include?(value)
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
    (settings[:values] || []).join("\n")
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
