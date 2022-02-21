class Kor::Storage
  VARIANTS = {
    'original' => {},

    'normal' => {if: :image?, type: 'im', extension: 'jpg', opts: {resize: '1440x1440>'}},
    'screen' => {if: :image?, type: 'im', extension: 'jpg', opts: {resize: '800x800>'}},
    'preview' => {if: :image?, type: 'im', extension: 'jpg', opts: {resize: '300x300>'}},
    'thumbnail' => {if: :image?, type: 'im', extension: 'jpg', opts: {resize: '140x140>'}},
    'icon' => {if: :image?, type: 'im', extension: 'jpg', opts: {resize: '80x80>'}},

    'cover' => {if: :video?, type: 'still', extension: 'jpg'},
    'mp4' => {if: :video?, type: 'mp4_video', extension: 'mp4'},
    'webm' => {if: :video?, type: 'webm_video', extension: 'webm'},
    'ogg.video' => {if: :video?, type: 'ogg_video', extension: 'ogv'},

    'mp3' => {if: :audio?, type: 'mp3', extension: 'mp3'},
    'ogg.audio' => {if: :audio?, type: 'ogg_audio', extension: 'ogg'}
  }

  def initialize(medium, attachment, options = {})
    @medium = medium
    @attachment = attachment

    @file_name = options[:file_name]
    @content_type = options[:content_type]
    @updated_at = options[:updated_at]
  end

  def assign_file(file, options = {})
    @file = file
    @content_type = options[:content_type]
    @file_name = options[:file_name]
    @updated_at = options[:updated_at]

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
  attr_reader :updated_at

  def save
    if @clear
      remove_variants original: true
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

  def clear
    @clear = true
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
    return true if @file
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

  def remove_variants(original: false)
    self.class::VARIANTS.each do |key, config|
      next if !original && key == 'original'

      rm variant_path(key)
    end
  end

  def build_variants
    self.class::VARIANTS.each do |key, config|
      next if key == 'original'
      next unless send(config[:if])

      infile = variant_path('original')
      outfile = variant_path(key)

      mkdir File.dirname(outfile)
      send(config[:type], infile, outfile, config[:opts])
    end
  end

  def rebuild_variants
    remove_variants
    build_variants
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

  def variant_extension(variant)
    if variant == 'original'
      @file_name ? @file_name.split('.').last : 'dat'
    else
      self.class::VARIANTS[variant][:extension]
    end
  end

  def variant_path(variant, extension = nil)
    extension ||= variant_extension(variant)
    "#{base_dir}/#{variant}/#{id_dirs}/#{@attachment}.#{extension}"
  end

  def variant_url(variant, disposition = 'inline')
    extension ||= variant_extension(variant)
    ts = @updated_at ? "?#{@updated_at}" : ''
    "/media/#{disposition}/#{variant}/#{id_dirs}/#{attachment}.#{extension}#{ts}"
  end

  def self.guess_content_type(path)
    r, w = IO.pipe
    success = system 'file', '-bi', path, out: w
    w.close

    if success
      r.read.split('; ').first
    end
  end

  def image?
    return false unless @content_type

    @content_type.match?(/^image\//)
  end

  def video?
    return false unless @content_type

    @content_type.match?(/^video\//)
  end

  def audio?
    return false unless @content_type

    @content_type.match?(/^audio\//)
  end


  protected

    def cp(infile, outfile, opts = {})
      mkdir File.dirname(outfile)
      Kor.system 'cp', infile, outfile
    end

    def mkdir(path)
      Kor.system 'mkdir', '-p', path
    end

    def rm(file)
      system 'rm', '-f', file
    end

    def im(infile, outfile, opts = {})
      cmd = ['magick', 'convert', infile]
      cmd += ['+profile', '*']

      if opts[:resize]
        cmd += ['-resize', opts[:resize]]
      end
      
      cmd << outfile
      Kor.system *cmd
    end

    def mp4_video(infile, outfile, opts = {})
      cmd = [
        'ffmpeg',
          '-loglevel', 'panic', '-nostats',
        '-i', infile,
          '-crf', '28',
          '-c:v', 'libx264',
          '-c:a', 'aac',
          '-b:a', '256k',
          '-strict', 'experimental',
          '-profile:v', 'baseline',
          '-level', '3.0',
          '-movflags', '+faststart',
        '-y', outfile
      ]

      Kor.system *cmd
    end

    def ogg_video(infile, outfile, opts = {})
      cmd = [
        'ffmpeg',
          '-loglevel', 'panic', '-nostats',
        '-i', infile,
          '-c:v', 'libtheora',
          '-qscale:v', '7',
          '-c:a', 'libvorbis',
          '-qscale:a', '3',
        '-y', outfile
      ]

      Kor.system *cmd
    end

    def webm_video(infile, outfile, opts = {})
      cmd = [
        'ffmpeg',
          '-loglevel', 'panic', '-nostats',
        '-i', infile,
          '-crf', '10',
          '-c:v', 'libvpx',
          '-b:v', '1M',
          '-c:a', 'libvorbis',
          '-qscale:a', '7',
        '-y', outfile
      ]

      Kor.system *cmd
    end

    def still(infile, outfile, opts = {})
      cmd = [
        'ffmpeg',
        '-ss', '00:00:05',
        '-i', infile,
          '-vframes', '1',
        '-y', outfile
      ]

      Kor.system *cmd
    end

    def mp3(infile, outfile, opts = {})
      cmd = [
        'ffmpeg',
        '-i', infile,
          '-c:a', 'libmp3lame',
          '-qscale:a', '3',
        '-y', outfile
      ]

      Kor.system *cmd
    end

    def ogg_audio(infile, outfile, opts = {})
      cmd = [
        'ffmpeg',
        '-i', infile,
          '-c:a', 'libvorbis',
          '-qscale:a', '3',
        '-y', outfile
      ]

      Kor.system *cmd
    end

    def id_dirs
      ("%09d" % @medium.id).scan(/\d{3}/).join('/')
    end

    def base_dir
      "#{ENV['DATA_DIR']}/media"
    end
end
