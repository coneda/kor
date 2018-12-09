module Kor
  
  def self.settings
    Kor::Settings.instance
  end
  
  def self.version
    File.read("#{Rails.root}/config/version.txt").strip
  end

  def self.commit
    File.read "#{Rails.root}/REVISION"
  rescue Errno::ENOENT => e
    nil
  end

  def self.source_code_url
    if version.match(/\-pre$/)
      if self.commit
        Kor.settings['sources_pre_release'].gsub(/\{\{commit\}\}/, Kor.commit)
      else
        Kor.settings['sources_default']
      end
    else
      Kor.settings['sources_release'].gsub(/\{\{version\}\}/, Kor.version)
    end
  end

  # TODO: this doesn't seem to work
  def self.repository_uuid
    # TODO: document that the old uuid has to be copied over!
    Kor.settings.fetch 'repository_uuid' do
      SecureRandom.uuid
    end
  end
 
  def self.session_expiry_time
    Time.now + Kor.settings['session_lifetime'].seconds
  end

  def self.publishment_expiry_time
    Kor.settings['publishment_lifetime'].days.from_now
  end

  def self.now
    Time.now.utc
  end
  
  def self.array_wrap(object)
    if object.is_a?(Array)
      object
    else
      [object]
    end
  end

  def self.id_for_model(object)
    if object.is_a?(Array)
      object.collect { |o| id_for_model(o) }
    else
      object.is_a?(ActiveRecord::Base) ? object.id : object
    end
  end

  def self.video_processor
    @video_processor ||= begin
      system('avconv -version > /dev/null 2> /dev/null') ? 'avconv' : 'ffmpeg'
    end
  end

  def self.progress_bar(title, total, options = {})
    options.reverse_merge!(
      :title => title,
      :total => total,
      :format => "%t: |%B|%R/s|%c/%C (%P%%)|%a%E|",
      :throttle_rate => 0.5
    )

    ProgressBar.create(options)
  end

  def self.is_uuid?(value)
    value.is_a?(String) &&
      !!value.match(/[\da-f]{8}-[\da-f]{4}-[\da-f]{4}-[\da-f]{4}-[\da-f]{12}/i)
  end

  def self.with_exclusive_lock(name, &block)
    mode = File::RDWR | File::CREAT
    File.open "#{Rails.root}/tmp/#{name}.lock", mode do |f|
      f.flock(File::LOCK_EX)
      yield
      f.flock(File::LOCK_UN)
    end
  end

  def self.root_url
    ENV['ROOT_URL']
  end

  def self.default_url_options(request = nil)
    uri = URI.parse(root_url)
    return {
      host: uri.host,
      port: uri.port,
      protocol: uri.scheme
    }
  end

  def self.tmp_path
    base = File.join(ENV['DATA_DIR'], 'processing')
    Tempfile.new(rand.to_s, base).path
  end
end
