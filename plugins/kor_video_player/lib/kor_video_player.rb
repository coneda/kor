module KorVideoPlayer
  class Engine < Rails::Engine
    config.autoload_paths << File.expand_path("..", __FILE__)
    
    initializer "kor_video_player.add_asset_path" do |app|
      app.assets.paths << "flash"
    end
  end
  # all sorts of stuff you had already maybe goes here
end
