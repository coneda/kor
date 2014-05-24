namespace :kor do

  task :reprocess_images => :environment do
    num = Medium.count
    left = num
    started_at = nil
    puts "Found #{num} media entities"
    
  
    Medium.find_each do |m|
      started_at ||= Time.now
      
      m.image.reprocess! if m.image.file?
      
      left -= 1
      seconds_left = (Time.now - started_at).to_f / (num - left) * left
      puts "#{left} items left (ETA: #{Time.now + seconds_left.to_i})"
    end
  end

  namespace :invalids do
    desc "re-validates all entities within the 'invalids' system group"
    task :check => :environment do
      group = SystemGroup.find_by_name('invalids')
      valids = group.entities.select do |entity|
        entity.valid?
      end
      
      puts "removing #{valids.count} from the 'invalids' system group"
      group.remove_entities valids
    end
  end

  namespace :users do
    desc "notify users if their account is going to expire soon"
    task :notify_upcoming_expiries => :environment do
      User.where("expires_at < ? AND expires_at > ?", 2.weeks.from_now, Time.now).each do |user|
        UserMailer.deliver_upcoming_expiry(user)
      end
    end
  end

  desc "resets the admin password to 'admin'"
  task :reset_admin_account => :environment do
    admin = User.find_by_name('admin')
    admin.password = 'admin'
    admin.plain_password_confirmation = 'admin'
    admin.login_attempts = []
    admin.admin!
    puts admin.save
  end
   
end
