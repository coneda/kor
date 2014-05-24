class Fields::String < Field

  serialize :settings

  def self.label
    'String'
  end

end
