class Paperclip::Empty < Paperclip::Processor

  def make
    Tempfile.new(rand.to_s)
  end
  
end
