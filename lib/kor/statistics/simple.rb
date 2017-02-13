class Kor::Statistics::Simple
  
  def initialize(options = {})
    @options = options
  end

  # TODO: use progress_bar  
  def run
    @counter = 0

    items.find_each do |item|
      report_progress
      
      process item
    end
  end

  def report_progress
    if @options[:verbose] && @counter % 20 == 0
      puts "processing #{@counter} out of #{total}"
    end
    
    @counter += 1
  end
  
  def items
    Entity.where("medium_id IS NOT NULL AND created_at >= ? AND created_at <= ?", @from, @to)
  end
    
  def total
    @total ||= items.count
  end
  
end
