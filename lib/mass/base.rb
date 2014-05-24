class Mass::Base
  
  def run(options = {})
    Entity.transaction do
      process(options)
    end
  end
  
  def process_merge(options = {})
    raise "needs to be implemented by derived classes"
  end
  
end
