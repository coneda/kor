class Kor::Statistics::Ranged < Kor::Statistics::Simple
  
  def initialize(from, to, options = {})
    @from = Time.parse(from) + 1.second
    @to = Time.parse(to) + 1.day - 1.second
    
    super options
  end
  
end
