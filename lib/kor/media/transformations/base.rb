class Kor::Media::Transformations::Base
  attr_accessor :options
  attr_accessor :medium

  def initialize(medium, options = {})
    @medium = medium
    @options = options
    
    raise "options #{options} are invalid" unless valid_options?
  end
  
  def self.operations
    []
  end
  
  def self.name
    to_s.split('::').last.underscore
  end
  
  def self.human_name
    I18n.t("media.transformations.#{name}.name")
  end
  
  def self.human_operation_name(operation)
    I18n.t("media.transformations.#{name}.operations.#{operation}")
  end
  
  def self.button_icon(operation)
    "media/transformations/#{name}/#{operation}.gif"
  end
  
  def valid_options?
    self.class.operations.include? options[:operation].to_sym
  end
  
  def self.image_path(options = {})
    raise "must be implemented by subclass"
  end

  def self.transforms(medium)
    raise "must be implemented by subclass"
  end
  
  def transform
    raise "must be implemented by subclass"
  end
  
end
