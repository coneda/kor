class Kor::Media::Transformations::Image < Kor::Media::Transformations::Base
  def self.transforms(medium)
    medium.image.file?
  end
  
  def self.operations
    [:flip, :flop, :rotate_cw, :rotate_ccw, :rotate_180]
  end
  
  def operation_to_command(operation)
    map = { :rotate_cw => 'rotate 90', :rotate_ccw => 'rotate -90', :rotate_180 => 'rotate 180' }
    map[operation] || operation
  end
  
  def transform
    file_name = medium.image.path
    command = operation_to_command(options[:operation])
    system "mogrify -#{command} #{file_name}"
    
    medium.image = File.open(file_name)
    medium.save
    
    medium
  end
  
end
