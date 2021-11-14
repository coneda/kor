class Kor::Storage
  def initialize(medium, attachment, uploads = {})
    @medium = medium
    @attachment = attachment

    @files = files.reverse_merge(
      'document' => nil,
      'image' => nil
    )
  end

  def save(file, original_extension)
    extension = file.extension.path.split('.').last
    cp file.path, variant_path('original', attachment, @medium.original_extension)

    # unless file.is_a?(ActionDispatch::Http::UploadedFile)
    #   file = ActionDispatch::Http::UploadedFile.new(
    #     type: x.
    #     filename: 
    #   )
    # end

    if file = @files[:image]
      extension = file.extension.path.split('.').last
      cp file.path, variant_path('original', 'image', @medium.original_extension)
    end
  end

  def destroy(file)

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
      build 'ogg', type: 'ffmpeg', extension: 'ogg'
    end

    if @medium.audio?
      build 'mp3', type: 'ffmpeg', extension: 'mp3'
      build 'ogg', type: 'ffmpeg', extension: 'ogg'
    end
  end


  protected

    def build_stream_copy(name, options)

      build name, options do |infile, outfile|

      end
    end

    def cp(infile, outfile, options = {})
      
    end

    def im(infile, outfile, options = {})

    end

    def ffmpeg(infile, outfile, options = {})

    end

    def variant_path(name, attachment, extension = nil)
      extension ||= name
      "#{base_dir}/#{name}/#{id_dirs}/#{attachment}.#{extension}"
    end

    def id_dirs
      ("%09d" % @medium.id).scan(/\d{3}/).join('/')
    end

    def base_dir
      "#{ENV['DATA_DIR']}/media"
    end
end
