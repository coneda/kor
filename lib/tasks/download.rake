namespace :kor do
  namespace :downloads do
    
    desc "expire old downloads"
    task :expire => :environment do
      Download.find(:all, :conditions => ['created_at < ?', 2.weeks.ago]).each do |download|
        download.destroy
      end
    end
  
  end
end
