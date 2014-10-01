namespace :kor do

  task :to_neo => :environment do
    graph = Kor::NeoGraph.new(User.admin)

    graph.reset!

    Relationship.includes(:from, :to, :relation).limit(100).find_each do |r|
      p "now #{Time.now} #{r.id}"
      if !r.to.is_medium? && !r.from.is_medium?
        graph.create r
      end
    end
  end

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

  namespace :recheck_invalid_entities do
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

  namespace :notify_expiring_users do
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

  desc "Package a group into a downloadable zip file"
  task :group_to_zip => :environment do
    klass = ENV["KLASS"].constantize
    group_id = ENV["GROUP_ID"].to_i
    group = klass.find(group_id)

    size = group.entities.media.map do |e|
      e.medium.image_file_size || e.medium.document_file_size || 0.0
    end.sum
    human_size = size / 1024 / 1024
    puts "Please be aware that"
    puts "* the download will be composed with the rights of the 'admin' user"
    puts "* the download will be approximately #{human_size} MB in size"
    puts "* the process is running synchronously, blocking your terminal"
    puts "* the file is going to be cleaned up two weeks after it has been created"
    print "Continue [yes/no]? "
    response = STDIN.gets.strip

    if response == "yes"
      zip_file = Kor::ZipFile.new("#{Rails.root}/tmp/terminal_download.zip", 
        :user_id => User.admin.id,
        :file_name => "#{group.name}.zip"
      )

      group.entities.media.each do |e|
        zip_file.add_entity e
      end

      download = zip_file.create_as_download
      puts "Packaging complete, the zip file can be downloaded via"
      puts download.link
    end
  end

  namespace :index do
    desc "drop the index"
    task :drop => :environment do
      Kor::Elastic.drop_index
    end

    desc "create the index"
    task :create => :environment do
      Kor::Elastic.create_index
    end

    desc "refresh the elastic index"
    task :refresh => [:environment, :drop, :create] do
      ActiveRecord::Base.logger.level = Logger::ERROR
      Kor::Elastic.index_all :full => true, :progress => true
    end

  end
   
end
