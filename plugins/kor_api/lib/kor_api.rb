module KorApi
  class Engine < Rails::Engine
    config.autoload_paths << File.expand_path("..", __FILE__)
  end
  # all sorts of stuff you had already maybe goes here
end
