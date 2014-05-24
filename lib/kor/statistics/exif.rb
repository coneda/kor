class Kor::Statistics::Exif < Kor::Statistics::Ranged
  
  def process(item)
    @medium = item.medium
    @exif = nil
    
    statistics[exif[:make]] ||= {}
    statistics[exif[:make]][exif[:model]] ||= 0
    statistics[exif[:make]][exif[:model]] += 1
  end
  
  def statistics
    @statistics ||= {}
  end
  
  def report
    puts "checked #{total} images (period: #{@from.strftime('%Y-%m-%d')} to #{@to.strftime('%Y-%m-%d')})"
    statistics.each do |make, models|
      puts "  #{make ? make : 'unknown'}"
      models.each do |model, num|
        puts "    #{model ? model : 'unknown'}: #{num}"
      end
    end
  end
  
  def content_type
    @medium.content_type.split('/').last.downcase
  end
  
  def file
    @medium.image.path :original
  end
  
  def exif
    @exif ||= begin
      result = {:make => nil, :model => nil}

      parser = if content_type.match /tiff?/
        EXIFR::TIFF.new(file)
      elsif content_type.match /jpe?g/
        EXIFR::JPEG.new(file)
      else
        nil
      end
      
      parser ? {:make => parser.make, :model => parser.model} : result
    rescue => e
      result
    end
  end
  
end
