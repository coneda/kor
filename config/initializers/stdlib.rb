class String

  def tokenize
    tokenize_token = true
    
    result = []
    self.split(/ *\" */).each do |qt|
      if tokenize_token
        result += qt.split
      else
        result << qt unless qt.empty?
      end
      tokenize_token = !tokenize_token
    end

    result
  end

  def capitalize
    self.mb_chars.capitalize.to_s
  end

  def capitalize_first_letter
    return '' if empty?
    
    result = self.mb_chars
    result[0] = result[0].upcase
    result.to_s
  end

  def short(how_short = 30)
    length > how_short ? first(how_short - 3).strip + "..." : self
  end

end