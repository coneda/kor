class Kor::Statistics::Exif < Kor::Statistics::Simple
  def initialize(from, to, options = {})
    @statistics = {}
    @from = Time.parse(from) + 1.second
    @to = Time.parse(to) + 1.day - 1.second

    super options
  end

  def report
    result = [
      "checked #{total} images " +
        "(period: #{@from.strftime('%Y-%m-%d')} to #{@to.strftime('%Y-%m-%d')})"
    ]
    @statistics.each do |make, models|
      result << "  #{make ? make : 'unknown'}"
      models.each do |model, num|
        result << "    #{model ? model : 'unknown'}: #{num}"
      end
    end
    result.join("\n")
  end

  def process(item)
    exif = self.class.exif_for(item)

    @statistics[exif[:make]] ||= {}
    @statistics[exif[:make]][exif[:model]] ||= 0
    @statistics[exif[:make]][exif[:model]] += 1
  end

  def self.exif_for(medium)
    result = { :make => nil, :model => nil }

    file = medium.medium.image.path :original
    content_type = medium.medium.content_type.split('/').last.downcase
    parser = if content_type.match(/tiff?/)
      EXIFR::TIFF.new(file)
    elsif content_type.match(/jpe?g/)
      EXIFR::JPEG.new(file)
    else
      nil
    end

    { :make => parser.make, :model => parser.model }
  rescue => e
    # raise e
    result
  end
end
