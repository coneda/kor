class Splitter
  def initialize(string)
    @string = string
  end
  
  def tokenize
    if @string.size > 15
      results = []
      (@string.size / 15).times do |i|
        low = i * 15
        high = (i + 1) * 15 - 1
        results << @string[low..high]
      end
      
      if results.size > 1
        results << @string[-15..-1]
      end
      
      results.map! do |r|
        r.gsub(/(^|\s+).(\s+|$)/, ' ').strip
      end
    else
      [@string]
    end
  end
end
