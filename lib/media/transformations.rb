module Media::Transformations end

Dir.glob("#{Rails.root}/lib/media/transformations/*.rb").each{|file| require_dependency file}

module Media::Transformations
  
  def self.base_transformation
    Media::Transformations::Base
  end
  
  def self.all_transformations
    constants.map{|p| "Media::Transformations::#{p}".constantize} - [base_transformation]
  end
  
  def self.transformations(medium)
    all_transformations.select{|p| p.transforms(medium)}
  end
  
end
