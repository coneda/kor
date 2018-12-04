class Kor::CommandLine

  def initialize(args)
    @args = args.dup
    @config = {
      format: "excel",
      username: "admin",
      ignore_stale: false,
      obey_permissions: false,
      simulate: false,
      ignore_validations: false,
      collection_id: [],
      kind_id: [],
      verbose: false
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
        @parser.on("-u USERAME", "the user to act as, default: admin") {|v| @config[:username] = v }
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
    when 'list-permissions'
        @parser.on('-e ENTITY', 'the id of an entity to limit the result list to') {|v| @config[:entity_id] = v}
        @parser.on('-u USER', 'the id of a user to limit the result list to') {|v| @config[:user_id] = v}
    end

    @parser.order!(@args)

    log "command: #{@command}"
    log "options: #{@config.inspect}"
  end

  def validate
    @required.each do |r|
      if @config[r].nil?
        STDERR.puts "please specify a value for '#{r}'"
        exit 1
      end
    end
  end

  def set(key, value)
    @config[key] = value
  end

  def task(name)
    Kor::Tasks.send(name, @config)
  end

  def run
    if @config[:help]
      usage
    else
      validate

      if @config[:timestamp]
        @config[:verbose] = true
        log Time.now
      end

      case @command
      when 'version' then version
      when 'export'
          if @config[:format] == 'excel'
            dir = @args.shift
            Kor::Export::Excel.new(dir, @config).run
          end
      when 'import'
          if @config[:format] == 'excel'
            dir = @args.shift
            Kor::Import::Excel.new(dir, @config).run
          end
      when 'reprocess-all' then task :reprocess_all
      when 'index-all' then task :index_all
      when 'group-to-zip' then task :group_to_zip
      when 'notify-expiring-users' then task :notify_expiring_users
      when 'recheck-invalid-entities' then task :recheck_invalid_entities
      when 'delete-expired-downloads' then task :delete_expired_downloads
      when 'editor-stats' then task :editor_stats
      when 'exif-stats' then task :exif_stats
      when 'reset-admin-account'
          log(
            "setting password of account 'admin' to 'admin' and " +
            "granting all rights"
          )
          task :reset_admin_account
      when 'reset-guest-account'
          log "creating guest account unless it already exists"
          task :reset_guest_account
      when 'to-neo' then task :to_neo
      when 'connect-random' then task :connect_random
      when 'cleanup-sessions' then task :cleanup_sessions
      when 'list-permissions' then task :list_permissions
      when 'cleanup-exception-logs' then task :cleanup_exception_logs
      when 'secrets' then task :secrets
      when 'consistency-check' then task :consistency_check
      when 'import-erlangen-crm' then task :import_erlangen_crm
        else
          STDERR.puts "command '#{@command}' is not known"
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

  protected

    def log(message)
      if @config[:verbose]
        puts message
      end
    end

end