class Paperclip::Video < Paperclip::Processor
  
  def initialize(file, options = {}, attachment = nil)
    super
    
    @file = file
    @options = options
    @attachment = attachment
    @medium = attachment.instance
  end
  
  def command(pass = 1)
    result = [
      "#{executable} -y",
      "-i #{original_path}",
      "-ar 22050",
      "-ab 128000",
      "-r 12",
      "-f flv",
      "-acodec libmp3lame",
      "-ac 1",
      "-passlogfile #{target}",
      "-pass #{pass}",
      "-b #{probe.suggested_video_bitrate}",
      "-s #{probe.suggested_width}x#{probe.suggested_height}",
      "2> /dev/null"
    ].join(" ")
    
    result << " #{target}"
    
    result
  end
  
  def still_command(use_original = true)
    time = (probe(target).attributes[:duration] * 0.2).to_i
    time_args = "#{time / 60 / 60}:#{(time / 60) % 60}:#{time % 60}"
    
    "#{executable} -itsoffset #{time_args} -i #{use_original ? original_path : target} -vframes 1 #{still_file} 2> /dev/null"
  end
  
  def still_file
    @still_file ||= "#{Rails.root}/tmp/stills/#{SecureRandom.uuid}.jpg"
  end
  
  def probe(file = nil)
    @probe =Kor::Media::VideoProber.new(original_path)
  end
  
  def target
    @target ||= Tempfile.new(rand.to_s).path + '.converted'
  end

  def original_path
    @medium.path(:original)
  end
  
  def original_is_flv?
    ['video/x-flv', 'application/x-shockwave-flash'].include? @medium.content_type
  end
  
  def system(command)
    # puts command
    Kernel.system command
  end
  
  def make
    result = true
  
    # flv conversion
    FileUtils.mkdir_p File.dirname(target)
    
    result &= system command(1)
    result &= system command(2)
    
    # still extraction
    if system(still_command) || system(still_command(false))
      @medium.image = File.open(still_file)
    end
    
    File.open(target)
  end

  def executable
    if system("which avconv > /dev/null 2> /dev/null")
      "avconv"
    else
      "ffmpeg"
    end
  end

end
