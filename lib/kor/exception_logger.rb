module Kor::ExceptionLogger

  def self.log(exception, info = nil)
    data = {
      kind: exception.class.to_s,
      message: exception.message,
      backtrace: exception.backtrace,
      info: info
    }

    File.open "#{Rails.root}/log/error.log", 'a+' do |f|
      f.flock(File::LOCK_EX)
      f.puts data.to_json
    end
  end

end