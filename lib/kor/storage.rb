class Kor::Storage
  VARIANTS = {
    'original' => {}


  }

  def initialize(medium, attachment, options = {})
    @medium = medium
    @attachment = attachment

    @file_name = options[:file_name]
    @content_type = options[:content_type]
  end

  def assign_file(file, options = {})
    @file = file
    @content_type = options[:content_type]
    @file_name = options[:file_name]

    if path = @file.is_a?(String)
      @file = File.open(path, 'rb')
    end

    if @file
      @content_type ||= self.class.guess_content_type(file.path)
      @file_name ||= @file.path.split('/').last
    end

    if file.nil?
      @clear = true
    else
      @clear = false
    end
  end

  attr_accessor :attachment
  attr_reader :medium
  attr_reader :original_filename

  def save
    if @clear
      remove_variants
      @clear = false
    end

    if @file
      cp @file.path, variant_path('original')
      @file = nil
    end
  end

  def clear_file
    @file = nil
    @file_name = nil
    @content_type = nil
  end

  # def clear
  #   self.new_file = nil
  #   @clear = true
  # end

  def destroy
    binding.pry
  end

  def file
    return nil if @clear
    return @file if @file
    return nil unless @medium.id

    path = variant_path('original')
    return nil unless File.exists?(path)

    File.open(path, 'rb')
  end

  def file?
    return false if @clear
    return true if @file && @file
    return false unless @medium.id

    File.exists?(variant_path('original'))
  end

  def content_type
    return nil if @clear
    return @content_type if @content_type
      
    @medium.send("#{@attachment}_content_type")
  end

  def size
    return nil if @clear
    return @file.size if @file

    @medium.send("#{@attachment}_file_size")
  end

  def remove_variants

  end

  def build_variants
    if @medium.image?
      # xl
      im variant_path('original', )

      build 'jpg-1440', type: 'im', resize: '1920x1920', from: 'original', extension: 'jpg'
      build 'jpg-800', type: 'im', resize: '800x800>', from: 'jpg-1440', extension: 'jpg'
      build 'jpg-320', type: 'im', resize: '320x320>', from: 'jpg-800', extension: 'jpg'
    end

    if @medium.video?
      build 'still', type: 'ffmpeg', extension: 'jpg'

      build 'mp4', type: 'ffmpeg', extension: 'mp4'
      build 'webm', type: 'ffmpeg', extension: 'webm'
      build 'ogg', type: 'ffmpeg', extension: 'ogv'
    end

    if @medium.audio?
      build 'mp3', type: 'ffmpeg', extension: 'mp3'
      build 'ogg', type: 'ffmpeg', extension: 'ogg'
    end
  end

  def variant_file(variant)
    return nil if @clear

    if variant == 'original'
      return @file if @file
      return nil unless @medium.id
    end

    path = variant_path(variant)
    File.exists?(path) ? File.open(path, 'rb') : nil
  end

  def variant_path(variant, extension = nil)
    extension ||= if variant == 'original'
      @file_name ? @file_name.split('.').last : 'dat'
    else
      variant
    end

    "#{base_dir}/#{variant}/#{id_dirs}/#{@attachment}.#{extension}"
  end

  def self.guess_content_type(path)
    r, w = IO.pipe
    success = system 'file', '-bi', path, out: w
    w.close

    if success
      r.read.split('; ').first
    end
  end


  protected

    def cp(infile, outfile, options = {})
      
    end

    def im(infile, outfile, options = {})

    end

    def ffmpeg(infile, outfile, options = {})

    end

    def id_dirs
      ("%09d" % @medium.id).scan(/\d{3}/).join('/')
    end

    def base_dir
      "#{ENV['DATA_DIR']}/media"
    end
end
