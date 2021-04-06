class Paperclip::Audio < Paperclip::Processor
  def self.make(file, options = {}, attachment = nil)
    case options[:style]
    when :mp3 then make_mp3(file, attachment)
    when :ogg then make_ogg(file, attachment)
    else
      file
    end
  end

  def self.make_mp3(file, attachment)
    outfile = "#{Kor.tmp_path}.mp3"
    args = "-qscale 3"
    args = "-i #{file.path} #{args} #{outfile}"
    Paperclip.run('ffmpeg', args)
    File.open(outfile)
  end

  def self.make_ogg(file, attachment)
    outfile = "#{Kor.tmp_path}.ogg"
    args = "-qscale 7"
    args = "-i #{file.path} #{args} #{outfile}"
    Paperclip.run('ffmpeg', args)
    File.open(outfile)
  end
end
