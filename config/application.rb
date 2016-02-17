require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

$: << File.expand_path('../../lib', __FILE__)

require 'kor'
require 'kor/config'
require 'securerandom'

module Kor
  class Application < Rails::Application
    config.autoload_paths << "#{Rails.root}/lib"

    config.assets.js_compressor = :uglifier
    config.assets.precompile += ["kor.js", "blaze.js", "master.css", "blaze.css", "kor_index.js", "kor_index.css"]

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.i18n.available_locales = [:de, :en]

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    config.active_job.queue_adapter = :delayed_job
  end
end

# TODO: remove console.log
# TODO: handle stale object errors on json apis
# TODO: user new validates instead of validates_*_of
# TODO: deal with 'legal' functionality
# TODO: ensure a correct message on success on all json responses when data was changed
# TODO: implement destroying relationships
# TODO: show images on relationships
# TODO: use jbuilder without exception for api reponses
# TOTO: remove redundant code and comments from old js files
# TODO: use the run command for delayed workers instead of the rake job (production)
# TODO: the entity selector should contain an option to include a given default
# TODO: handle empty relation list
# TODO: make sure that time zones are handled correctly from http content type to db
# TODO: fix serialized column initializers
# TODO: remove ArgumentArray
# TODO: clean up asset manifest files
# TODO: make sure the media kind is properly configured not to show fields on
# the input form. This has to be done on db seed, probably
# TODO: fix #1651 (redmine)
# TODO: add scenario for an empty resultset on the gallery
# TODO: remove comments

# module Kor
#   class Application < Rails::Application
    
#     # I18n
#     config.i18n.available_locales = [:de, :en]
#     config.i18n.enforce_available_locales = true
#     config.i18n.default_locale = Kor.config["app.default_locale"] || :en
#     config.i18n.load_path += Dir.glob("#{Rails.root}/config/locales/**/*.yml")
    
#     # Autoload paths
#     config.autoload_paths += %W(#{Rails.root}/lib)
    
#     File.umask Kor.config['umask']
  
#     config.assets.enabled = true
#     config.assets.initialize_on_precompile = false
#     config.assets.precompile += ["kor.js", "blaze.js", "master.css", "blaze.css", "kor_index.js", "kor_index.css"]
  
#     config.cache_store = :file_store, 'tmp/cache'
    
#     config.action_mailer.delivery_method = (Kor.config['mail_delivery_method'].presence || :smtp).to_sym
#     config.action_mailer.smtp_settings = Kor.config['mail'].symbolize_keys
#     config.action_mailer.sendmail_settings = {:arguments => "-i"}
#     config.action_mailer.default_url_options = Kor.config['host'].symbolize_keys
  
#     config.action_view.field_error_proc = Proc.new do |html_tag, instance|
#       "<span class='field_with_errors'>#{html_tag}</span>".html_safe
#     end

#     # Configure the default encoding used in templates for Ruby 1.9.
#     config.encoding = "utf-8"
#     config.active_record.default_timezone = :utc

#     # Configure sensitive parameters which will be filtered from the log file.
#     config.filter_parameters << :password
#   end
# end
