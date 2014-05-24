require "exifr"

namespace :kor do
  namespace :statistics do
  
    desc "count photographies"
    task :image_sources => :environment do
      stats = Kor::Statistics::Exif.new(ENV['from'], ENV['to'], :verbose => true)
      stats.run
    end
    
    desc "entities created and modified per user"
    task :users => :environment do
      stats = Kor::Statistics::Users.new(:verbose => true)
      stats.run
    end
    
  end
end
