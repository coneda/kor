# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
Rails.application.config.assets.precompile += [
  "Moxie.swf",
  "Moxie.xap"
]

# This shouldn't be necessary but otherwise, assets:precompile always touches
# the db
unless Rails.groups.include?('assets')
  Rails.application.config.session_store :active_record_store, key: '_kor_session'
end