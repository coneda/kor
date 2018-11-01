module Kor
  
  def self.settings
    Kor::Settings.instance
  end
  
  def self.help(controller, action)
    # TODO: implement this via a model per page-tag (widgets)
    # settings['help'][I18n.locale]['controller#action']
    # @help ||= begin
    #   file = "#{Rails.root}/config/help.yml"
    #   if File.exists? file
    #     YAML.load_file(file)['de']
    #   else
    #     {}
    #   end
    # end
    
    # @help['help'][controller][action]
    ''
  rescue => e
    ''
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
 
  # def self.base_url
  #   "#{settings['host']['protocol']}://#{config['host']['host']}" +
  #     (config['host']['port'] == 80 ? '' : ":#{config['host']['port']}" )
  # end

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
      object.collect{|o| id_for_model(o) }
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

  def self.default_url_options(request = nil)
    filename = Rails.root.join('tmp', 'default_url_options.json')

    if request
      options = {
        host: request.host,
        port: request.port,
        protocol: request.protocol
      }

      if !File.exists?(filename) || Rails.env.development?
        File.open filename, 'w' do |f|
          f.write options.to_json
        end
      end

      options
    else
      JSON.parse(File.read(filename)).symbolize_keys
    end
  end
end
