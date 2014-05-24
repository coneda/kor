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
    
  end

end
