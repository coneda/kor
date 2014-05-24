class Kor::Statistics::Ratings < Kor::Statistics::Simple
  
  def items
    Entity.scoped
  end
  
  def process(item)
    ratings = item.ratings.where(:namespace => '2d3d', :user_id => User.first.id)
  
    value = ratings.map{|r| r.data}
    
    if value.empty?
      value = ""
    else
      value = value.sum.sort.join(',')
    end
  
    result = {
      :id => item.id,
      :kind_name => item.kind.name,
      :ratings => value
    }
    
    statistics << result
  end
  
  def statistics
    @statistics ||= Array.new
  end
  
  def report
    puts "entities and their ratings (total: #{@total})"
    puts Hirb::Helpers::AutoTable.render(statistics,
      :fields => [:id, :kind_name, :ratings]
    )
  end
  
end
