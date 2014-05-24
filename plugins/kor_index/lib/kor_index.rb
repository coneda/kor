#Sass::Plugin.add_template_location(
#  "#{Rails.root}/public/plugin_assets/kor_index/stylesheets/sass",
#  "#{Rails.root}/public/plugin_assets/kor_index/stylesheets"
#)

module KorIndex
  class Engine < Rails::Engine
    config.autoload_paths << File.expand_path("..", __FILE__)
    config.paths['config/locales'] << 'config/locales/*'
  end
  # all sorts of stuff you had already maybe goes here
end
