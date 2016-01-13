class Kor::CommandLine

  def initialize(args)
    @args = args.dup
    @config = {
      :format => "excel",
      :username => "admin",
      :ignore_stale => false,
      :obey_permissions => false,
      :simulate => false,
      :ignore_validations => false,
      :collection_id => [],
      :kind_id => []
    }
    @required = []
    @command = nil

    @parser = OptionParser.new
  end

  def parse_options
    @parser.version = Kor.version
    @parser.banner = File.read("#{Rails.root}/config/banner.txt")

    @parser.on("--version", "print the version") { @command = "version" }
    @parser.on("-v", "--verbose", "run in verbose mode") { @config[:verbose] = true }
    @parser.on("-h", "--help", "print available options and commands") { @config[:help] = true }
    @parser.on("--debug", "the user to act as, default: admin") { @config[:debug] = true }
    @parser.on("--timestamp", "print a timestamp before doing anything") { @config[:timestamp] = true }
    @parser.separator ""

    @parser.order!(@args)

    @command ||= @args.shift

    if @command == "import" || @command == "export"
      
    end

    case @command
      when "export"
        @parser.on("-f FORMAT", "the format to use, supported values: [excel], default: excel") {|v| @config[:format] = v }
        @parser.on("--collection-id=IDS", "export only the given collections, may contain a comma separated list of ids") {|v| @config[:collection_id] = v.split(",").map{|v| v.to_i} }
        @parser.on("--kind-id=IDS", "export only the given kinds, may contain a comma separated list of ids") {|v| @config[:kind_id] = v.split(",").map{|v| v.to_i} }
        @required += [:format]
      when "import"
        @parser.on("-f FORMAT", "the format to use, supported values: [excel], default: excel") {|v| @config[:format] = v }
        @parser.on("-u USERAME", "the user to act as, default: admin") {|v| @config[:username] = v }
        @parser.on("-i", "write objects even if they are stale, default: false") { @config[:ignore_stale] = true }
        @parser.on("-p", "obey the permission system, default: false") { @config[:obey_permissions] = true }
        @parser.on("-s", "for imports: don't make any changes, default: false, implies verbose") { @config[:simulate] = true }
        @parser.on("-o", "ignore all validations") { @config[:ignore_validations] = true }
        @required += [:format]
      when "group-to-zip"
        @parser.on("--group-id=ID", "select the group to package") {|v| @config[:group_id] = v.to_i }
        @parser.on("--class-name=NAME", "select the group klass to package") {|v| @config[:class_name] = v }
        @required += [:group_id, :class_name]
      when "exif-stats"
        @parser.on("-f DATE", "the lower bound for the time period to consider (YYYY-MM-DD)") {|v| @config[:from] = v }
        @parser.on("-t DATE", "the upper bound for the time period to consider (YYYY-MM-DD)") {|v| @config[:to] = v }
        @required += [:from, :to]
    end

    @parser.order!(@args)

    if @config[:verbose]
      puts "command: #{@command}"
      puts "options: #{@config.inspect}"
    end
  end

  def validate
    @required.each do |r|
      if @config[r].nil?
        puts "please specify a value for '#{r}'"
        exit 1
      end
    end
  end

  def run
    if @config[:help]
      usage
    else
      validate

      if @config[:timestamp]
        puts Time.now
      end

      case @command
        when "version" then version
        when "export"
          if @config[:format] == "excel"
            excel_export
          end
        when "import" 
          if @config[:format] == "excel"
            excel_import
          end
        when "reprocess-all" then reprocess_all
        when "index-all" then index_all
        when "group-to-zip" then group_to_zip
        when "notify-expiring-users" then notify_expiring_users
        when "recheck-invalid-entities" then recheck_invalid_entities
        when "delete-expired-downloads" then delete_expired_downloads
        when "editor-stats" then editor_stats
        when "exif-stats" then exif_stats
        when "reset-admin-account" then reset_admin_account
        when "cleanup-sessions" then cleanup_sessions
        else
          puts "command '#{@command}' is not known"
          usage
      end
    end
  end

  def usage
    puts @parser
  end

  def version
    puts Kor.version
  end

  def excel_export
    dir = @args.shift
    Kor::Export::Excel.new(dir, @config).run
  end

  def excel_import
    dir = @args.shift
    Kor::Import::Excel.new(dir, @config).run
  end

  def reprocess_all
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

  def index_all
    Kor::Elastic.drop_index
    Kor::Elastic.create_index
    ActiveRecord::Base.logger.level = Logger::ERROR
    Kor::Elastic.index_all :full => true, :progress => true
  end

  def group_to_zip
    klass = @config[:class_name].constantize
    group_id = @config[:group_id]
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

  def notify_expiring_users
    User.where("expires_at < ? AND expires_at > ?", 2.weeks.from_now, Time.now).each do |user|
      UserMailer.deliver_upcoming_expiry(user)
    end
  end

  def recheck_invalid_entities
    group = SystemGroup.find_by_name('invalids')
    valids = group.entities.select do |entity|
      entity.valid?
    end
    
    puts "removing #{valids.count} from the 'invalids' system group"
    group.remove_entities valids
  end

  def delete_expired_downloads
    Download.find(:all, :conditions => ['created_at < ?', 2.weeks.ago]).each do |download|
      download.destroy
    end
  end

  def editor_stats
    Kor::Statistics::Users.new(:verbose => true).run
  end

  def exif_stats
    require "exifr"
    Kor::Statistics::Exif.new(@config[:from], @config[:to], :verbose => true).run
  end

  def reset_admin_account
    User.admin.update_attributes(
      :password => "admin",
      :login_attempts => []
    )
  end

  def cleanup_sessions
    model = Class.new(ActiveRecord::Base)
    model.table_name = "sessions"
    model.where("created_at < ?", 5.days.ago).delete_all
  end

end