require File.expand_path('../boot', __FILE__)

require 'rails/all'

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
if defined?(Bundler)
  Bundler.require *Rails.groups(:assets => %w(development test))
  Bundler.require(:default, :assets, Rails.env)
end

$: << File.expand_path(File.dirname(__FILE__) + "/../lib")
require 'kor'
require 'kor/config'

module Kor
  class Application < Rails::Application
    
    # I18n
    config.i18n.available_locales = [:de, :en]
    config.i18n.enforce_available_locales = true
    config.i18n.default_locale = :de
    config.i18n.load_path += Dir.glob("#{Rails.root}/config/locales/**/*.yml")
    
    # Autoload paths
    config.autoload_paths += %W(#{Rails.root}/lib)
#    config.autoload_paths += Dir["#{Rails.root}/lib/**/"]
    config.autoload_paths += Dir["#{Rails.root}/middleware/*"]
    
    # Force all environments to use the same logger level
    # (by default production uses :info, the others :debug)
    # config.log_level = :debug
  
    # Make Time.zone default to the specified zone, and make Active Record store time values
    # in the database in UTC, and return them converted to the specified local zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Uncomment to use default local time.
    config.time_zone = 'Berlin'
    config.active_record.default_timezone = :utc
  
    File.umask Kor.config['umask']
  
    config.assets.enabled = true
  
    config.cache_store = :file_store, 'tmp/cache'
    
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = Kor.config['mail'].symbolize_keys
    config.action_mailer.default_url_options = Kor.config['host'].symbolize_keys
  
    config.action_view.field_error_proc = Proc.new do |html_tag, instance|
      "<span class='field_with_errors'>#{html_tag}</span>".html_safe
    end

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters << :password
  end
end
