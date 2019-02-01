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

  def self.make_mp4(file, attachment)
    outfile = Tempfile.new(rand.to_s).path + '.mp4'
    args = "-c:v libx264 -crf 28 -c:a aac -b:a 256k -strict experimental"
    args = "-loglevel panic -nostats -i #{file.path} #{args} #{outfile}"
    Paperclip.run(Kor.video_processor, args)
    File.open(outfile)
  end

  def self.make_ogg(file, attachment)
    outfile = Tempfile.new(rand.to_s).path + '.ogv'
    args = "-c:v libtheora -qscale:v 7 -c:a libvorbis -qscale:a 7"
    args = "-loglevel panic -nostats -i #{file.path} #{args} #{outfile}"
    Paperclip.run(Kor.video_processor, args)
    File.open(outfile)
  end

  def self.make_webm(file, attachment)
    outfile = Tempfile.new(rand.to_s).path + '.webm'
    args = "-c:v libvpx -crf 10 -b:v 1M -c:a libvorbis -qscale:a 7"
    args = "-loglevel panic -nostats -i #{file.path} #{args} #{outfile}"
    Paperclip.run(Kor.video_processor, args)
    File.open(outfile)
  end
end