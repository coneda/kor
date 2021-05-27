class Paperclip::Video < Paperclip::Processor
  def self.make(file, options = {}, attachment = nil)
    case options[:style]
    when :mp4 then make_mp4(file, attachment)
    when :ogg then make_ogg(file, attachment)
    when :webm then make_webm(file, attachment)
    else
      file
    end
  end

  # see https://trac.ffmpeg.org/wiki/Encode/H.264 and
  # https://stackoverflow.com/a/9477756/351909
  # TODO: baseline profile and flags should be applied to all formats?
  def self.make_mp4(file, attachment)
    make_still(file, attachment)

    outfile = "#{Kor.tmp_path}.mp4"
    args = "-c:v libx264 -crf 28 -c:a aac -b:a 256k -strict experimental -profile:v baseline -level 3.0 -movflags +faststart"
    args = "-loglevel panic -nostats -i #{file.path} #{args} -y #{outfile}"
    Paperclip.run('ffmpeg', args)
    File.open(outfile)
  end

  def self.make_ogg(file, attachment)
    outfile = "#{Kor.tmp_path}.ogv"
    args = "-c:v libtheora -qscale:v 7 -c:a libvorbis -qscale:a 7"
    args = "-loglevel panic -nostats -i #{file.path} #{args} -y #{outfile}"
    Paperclip.run('ffmpeg', args)
    File.open(outfile)
  end

  def self.make_webm(file, attachment)
    outfile = "#{Kor.tmp_path}.webm"
    args = "-c:v libvpx -crf 10 -b:v 1M -c:a libvorbis -qscale:a 7"
    args = "-loglevel panic -nostats -i #{file.path} #{args} -y #{outfile}"
    Paperclip.run('ffmpeg', args)
    File.open(outfile)
  end

  def self.make_still(file, attachment)
    outfile = "#{Kor.tmp_path}.jpg"
    args = "-ss 00:00:05 -i #{file.path} -vframes 1 -y #{outfile}"
    Paperclip.run('ffmpeg', args)
    attachment.instance.image = File.open(outfile)
  end
end
