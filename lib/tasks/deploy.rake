namespace :kor do
  namespace :deploy do

    desc "make asset links for all installed plugins"
    task :plugin_assets => :environment do
      FileUtils.mkdir_p("#{Rails.root}/public/plugin_assets")
    
      Dir.glob("#{Rails.root}/vendor/plugins/kor_*/assets").each do |target|
        plugin = target.split('/')[-2]
        link = "#{Rails.root}/public/plugin_assets/#{File.basename(plugin)}"
        
        system "rm -f #{link}"
        system "ln -s #{target} #{link}" if File.exists?(target)
      end
    end
    
    desc "copy the default content_type files to the public folder unless they exists"
    task :media_preview do
      origin = "#{Rails.root}/config/templates/content_types"
      destination = "#{Rails.root}/public/media"
      system "cp -a #{origin} #{destination}"
    end

  end

end
