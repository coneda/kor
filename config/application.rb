require File.expand_path('../boot', __FILE__)

require 'rails/all'

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
if defined?(Bundler)
  # Bundler.require *Rails.groups(:assets => %w(development test))
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
    config.i18n.default_locale = Kor.config["app.default_locale"] || :en
    config.i18n.load_path += Dir.glob("#{Rails.root}/config/locales/**/*.yml")
    
    # Autoload paths
    config.autoload_paths += %W(#{Rails.root}/lib)
    
    File.umask Kor.config['umask']
  
    config.assets.enabled = true
    config.assets.initialize_on_precompile = false
  
    config.cache_store = :file_store, 'tmp/cache'
    
    config.action_mailer.delivery_method = (Kor.config['mail_delivery_method'].presence || :smtp).to_sym
    config.action_mailer.smtp_settings = Kor.config['mail'].symbolize_keys
    config.action_mailer.sendmail_settings = {:arguments => "-i"}
    config.action_mailer.default_url_options = Kor.config['host'].symbolize_keys
  
    config.action_view.field_error_proc = Proc.new do |html_tag, instance|
      "<span class='field_with_errors'>#{html_tag}</span>".html_safe
    end

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"
    config.active_record.default_timezone = :utc

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters << :password
  end
end
