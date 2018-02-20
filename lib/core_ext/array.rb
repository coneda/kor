class Array

  def request?(property)
    self.include?(property) || self.include?('all')
  end

end