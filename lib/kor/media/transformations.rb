module Kor::Media::Transformations end

Dir.glob("#{Rails.root}/lib/kor/media/transformations/*.rb").each{ |file| require_dependency file }

module Kor::Media::Transformations
  def self.base_transformation
    Kor::Media::Transformations::Base
  end

  def self.all_transformations
    constants.map{ |p| "Kor::Media::Transformations::#{p}".constantize } - [base_transformation]
  end

  def self.transformations(medium)
    all_transformations.select{ |p| p.transforms(medium) }
  end
end
