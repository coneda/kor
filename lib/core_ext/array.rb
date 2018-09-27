class Array
  def request?(property)
    self.include?(property) || self.include?('all')
  end

  def self.wrap(object)
    if object.nil?
      []
    elsif object.respond_to?(:to_ary)
      object.to_ary || [object]
    else
      [object]
    end
  end
end