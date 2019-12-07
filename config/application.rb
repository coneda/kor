require File.expand_path('../boot', __FILE__)

require 'active_record/railtie'
require "action_controller/railtie"
require "action_mailer/railtie"

ENV['DISABLE_DATABASE_ENVIRONMENT_CHECK'] = '1'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# Set the app root so that dotenv can make it available in .env files
ENV['KOR_ROOT'] = File.expand_path(__dir__ + '/..')
require File.expand_path(__dir__ + '/../dotenv')
system "mkdir -p #{ENV['DATA_DIR']}"
system "mkdir -p #{ENV['KOR_ROOT']}/tmp"
system "mkdir -p #{ENV['DATA_DIR']}/processing"

$: << File.expand_path('../../lib', __FILE__)

require 'core_ext/array'
require 'kor'
require 'securerandom'

Dir["lib/paperclip_processors/*.rb"].each{ |f| require File.expand_path(f) }

module Kor
  class Application < Rails::Application
    config.autoload_paths << "#{Rails.root}/lib"
    config.eager_load_paths << "#{Rails.root}/lib"

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.i18n.available_locales = [:de, :en]

    config.active_job.queue_adapter = :async
    config.active_job.queue_name_prefix = "kor"

    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins(*(ENV['CORS_ALLOWED_ORIGINS'] || '').split(/\s+/))
        resource '*', headers: :any, methods: [:get, :options]
      end
    end

    config.action_dispatch.perform_deep_munge = false

    dm = ENV['MAIL_DELIVERY_METHOD']
    config.action_mailer.delivery_method = dm

    if dm == 'sendmail'
      config.action_mailer.sendmail_settings = {
        location: ENV['MAIL_SENDMAIL_LOCATION'],
        arguments: ENV['MAIL_SENDMAIL_ARGUMENTS']
      }
    end

    if dm == 'smtp'
      config.action_mailer.smtp_settings = {
        address: ENV['MAIL_SMTP_ADDRESS'],
        port: ENV['MAIL_SMTP_PORT'],
        domain: ENV['MAIL_SMTP_DOMAIN'],
        user_name: ENV['MAIL_SMTP_USER_NAME'],
        password: ENV['MAIL_SMTP_PASSWORD'],
        authentication: ENV['MAIL_SMTP_AUTHENTICATION'],
        enable_starttls_auth: ENV['MAIL_SMTP_ENABLE_STARTTLS_AUTO'] == 'true',
        openssl_verify_mode: ENV['MAIL_SMTP_OPENSSL_VERIFY_MODE']
      }
    end
  end
end

# TODO: test random query for more than 4 entities
# TODO: merge entity group tables?
# TODO: when deleting relationships and that completely empties the second or a
#       higher page, the previous page should be loaded
# TODO: make sure that time zones are handled correctly from http content type to db
# TODO: make image and video styles configurable live
# TODO: develop commenting policy
# TODO: remove comments everywhere
# TODO: re-enable still extraction for videos
# TODO: make an indicator for not-yet-processed media (use special dummy)
# TODO: rename Field.show_label to Field.label
# TODO: use "tsort" from stdlib to find graph communities?
# TODO: use neo transactions to effectively clear the store after tests
# TODO: make password retrieval not reset the password until the confirmation
#       link within the email was clicked
# TODO: make sure terms_accepted? is respected by all controllers and actions
# TODO: test changing of kind inheritance to update their entities dataset and
#       that relation inheritance uses the ancestry to show abailable relations
#       when creating relationships
# TODO: change name of credentials class
# TODO: change piwik and custom css to a more generic html include possibility
#       for the end of the header and the end of the body
# TODO: add ONE validation test to each controller/request suite
# TODO: add tests for validation handling to controllers (one example per resource)
# TODO: write all task specs
# TODO: add medium reprocess action that can be triggered via web
# TODO: create missing controller tests, look at coverage report for specs only
# TODO: test version task
# TODO: finish rubocop pass
# TODO: document rubocop usage: bundle exec rubocop -D -E -R -S
# TODO: remove brittle check from oai schema tests
# TODO: allow (relation specific) default dating label for relations
# TODO: newly created users should be activated by default