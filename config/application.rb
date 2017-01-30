require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

$: << File.expand_path('../../lib', __FILE__)

require 'kor'
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

    config.middleware.insert_before 0, "Rack::Cors" do
      allow do
        origins *Kor::Config.instance['allowed_origins']
        resource '*', headers: :any, methods: [:get, :options]
      end
    end

    initializer 'action_mailer.set_configs' do
      if mc = Kor::Config.instance['mail']
        dm = mc['delivery_method'].to_sym
        config.action_mailer.delivery_method = dm
        c = (mc["#{dm}_settings"] || {}).symbolize_keys
        config.action_mailer.send("#{dm}_settings=".to_sym, c)
      end
    end

  end
end

# TODO: better test fields_controller.rb
# TODO: better test generators_controller.rb
# TODO: test putting a whole authority group to the clipboard
# TODO: test random query for more than 4 entities
# TODO: test mailers and that they are used
# TODO: move all js templates to misc.html.erb or partial them from there
# TODO: test downloads_controller
# TODO: make sure there are tests for storing serialized attributes: dataset,
#       properties, datings, synonyms, relationship properties
# TODO: merge entity group tables?
# TODO: add @javascript tag to all feature tests
# TODO: when deleting relationships and that completely empties the second or a
#       higher page, the previous page should be loaded
# TODO: integration tests for tools: mass_destroy, add_to_authority_group, 
#       add_to_user_group, move_to_collection, remove_from_authority_group,
#       remove_from_user_group
# TODO: integration test for reset clipboard
# TODO: make sure in js kind_id == 1 isn't assumed to ensure medium kind
# TODO: remove new_datings_attributes and existing_datings_attributes
# TODO: upgrade elasticsearch
# TODO: move logic from command_line.rb to the service layer
# TODO: add tests for the command line tool
# TODO: make sure that time zones are handled correctly from http content type to db
# TODO: angular: remove flashing of unloaded page areas and remove flashing of strange "select <some HEX>" within media relations
# TODO: handle stale object errors on json apis
# TODO: use jbuilder without exception for api responses
# TODO: make image and video styles configurable live
# TODO: develop commenting policy
# TODO: replace fake_authentication and classic data_helper
# TODO: check helpers for redundant code
# TOTO: remove redundant code and comments from old js files
# TODO: remove comments everywhere
# TODO: re-enable still extraction for videos
# TODO: make an indicator for not-yet-processed media (use special dummy)
# TODO: use https://github.com/bkeepers/dotenv
# TODO: session panel is not visible on welcome page
# TODO: unify test setup steps
# TODO: unify default params and sanitation for pagination scopes
# TODO: instead of describing config defaults in the readme, refer to kor.defaults.yml which should also yield descriptions
# TODO: clean up translation files (remove obsolete models)
# TODO: when replacing sprockets, simulate checksum behaviour to provoke correct cache expiries
# TODO: use json.extract! whenever possible
# TODO: replace extended json views with customized json views
# TODO: change denied redirect to denied action rendering