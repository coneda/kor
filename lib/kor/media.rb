module Kor::Media
 
  def self.transform(medium, transformation, options = {})
    if transformation.transforms(medium)
      transformation.new(medium, options).transform.touch
    else
      raise "#{transformation.class} can not handle medium #{medium.id}"
    end
  end
  
  def self.transformations(medium)
    Transformations.transformations(medium)
  end
  
  def self.transformation_by_name(name)
    Transformations.all_transformations.select { |t| t.name == name }.first
  end
  
end
