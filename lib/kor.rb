module Kor
  
  def self.env_part
    Rails.env == 'production' ? '' : "#{Rails.env}."
  end
  
  def self.config_root
    "#{Rails.root}/config"
  end

  def self.default_config_file
    "#{config_root}/kor.defaults.yml"
  end
  
  def self.config_file
    "#{config_root}/kor.yml"
  end
  
  def self.app_config_file
    "#{config_root}/kor.app.#{env_part}yml"
  end

  def self.config(reload = (Rails.env == 'development'))
    if reload || @config.blank?
      @config = Kor::Config.new(default_config_file, config_file, app_config_file)
    end
    
    @config
  end
  
  def self.help(controller, action)
    @help ||= begin
      file = "#{Rails.root}/config/help.yml"
      if File.exists? file
        YAML.load_file(file)['de']
      else
        {}
      end
    end
    
    @help['help'][controller][action]
  rescue => e
    ""
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
        Kor.config["app.sources.pre_release"].gsub(/\{\{commit\}\}/, Kor.commit)
      else
        Kor.config['app.sources.default']
      end
    else
      Kor.config["app.sources.release"].gsub(/\{\{version\}\}/, Kor.version)
    end
  end

  def self.repository_uuid
    unless Kor.config["maintainer.repository_uuid"]
      Kor.config["maintainer.repository_uuid"] = SecureRandom.uuid
      Kor.config(false).store Kor.app_config_file
    end

    Kor.config["maintainer.repository_uuid"]
  end
 
  def self.base_url
    "#{config['host']['protocol']}://#{config['host']['host']}" +
      (config['host']['port'] == 80 ? '' : ":#{config['host']['port']}" )
  end


  # TODO: remove if tests pass
  # def self.logger
  #   unless @logger
  #     @logger = Logger.new( Kor.config['logging']['file'] )
  #     @logger.level = case Kor.config['logging']['level']
  #       when 'debug' then Logger::DEBUG
  #       when 'info' then Logger::INFO
  #       when 'warn' then Logger::WARN
  #       when 'error' then Logger::ERROR
  #       when 'fatal' then Logger::FATAL
  #       else Logger::UNKNOWN
  #     end
  #   end
  #   @logger
  # end

  # def self.log_message(progname, message)
  #   "#{Time.now.strftime('%Y-%m-%d %H:%M:%S')} >> #{progname}: #{message}"
  # end

  # def self.debug(progname, message)
  #   logger.debug log_message(progname, message)
  # end

  # def self.info(progname, message)
  #   logger.info log_message(progname, message)
  # end

  ####################### expiries #############################################

  def self.session_expiry_time
    Time.now + Kor.config['auth']['session_lifetime'].seconds
  end

  def self.publishment_expiry_time
    Kor.config['auth']['publishment_lifetime'].days.from_now
  end

  def self.now
    Time.now.utc
  end
  
  def self.notify_expiring_users
    users = User.where("expires_at < ? AND expires_at > ?", 2.weeks.from_now, Time.now)
    users.each do |user|
      UserMailer.upcoming_expiry(user).deliver_now
    end
    Rails.logger.info "Upcoming expiries: notified #{users.size} users"
  end

  def self.ensure_admin_account!
    u = User.find_or_initialize_by name: 'admin'
    u.update_attributes(
      groups: Credential.all,
      password: 'admin',
      terms_accepted: true,

      admin: true,
      relation_admin: true,
      authority_group_admin: true,
      kind_admin: true,

      full_name: u.full_name || I18n.t('users.administrator'),
      email: u.email || Kor.config['maintainer.mail']
    )
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
    system('hash avconv') ? 'avconv' : 'ffmpeg'
  end

end
