class Kor::CommandLine

  include Mixlib::CLI

  banner(File.read "#{Rails.root}/config/banner.txt")

  option(:format,
    :default => "excel",
    :short => "-f FORMAT",
    :description => "the format to use, supported values: [excel], default: excel"
  )
  option(:username,
    :default => "admin",
    :short => "-u USERNAME",
    :description => "the user to act as, default: admin"
  )
  option(:ignore_stale,
    :default => false,
    :boolean => true,
    :short => "-i",
    :description => "write objects even if they are stale, default: false"
  )
  option(:obey_permissions,
    :default => false,
    :boolean => true,
    :short => "-p",
    :description => "obey the permission system, default: false"
  )
  option(:simulate,
    :default => false,
    :boolean => true,
    :short => "-s",
    :description => "for imports: don't make any changes, default: false, implies verbose"
  )
  option(:verbose,
    :default => false,
    :boolean => true,
    :short => "-v",
    :description => "turn on verbose output"
  )
  option(:ignore_validations,
    :default => false,
    :boolean => true,
    :short => "-o",
    :description => "ignore all validations"
  )

  option(:collection_id,
    :default => [],
    :long => "--collection-id=IDS",
    :description => "export only the given collections, may contain a comma separated list of values",
    :on => :tail,
    :proc => Proc.new{|value| value.split(",").map{|v| v.to_i}}
  )
  option(:kind_id,
    :default => [],
    :long => "--kind-id=IDS",
    :description => "export only the given kinds, may contain a comma separated list of values",
    :on => :tail,
    :proc => Proc.new{|value| value.split(",").map{|v| v.to_i}}
  )
  option(:debug,
    :default => false,
    :boolean => true,
    :short => "-d",
    :description => "turn on debug mode"
  )

  def run
    if config[:debug]
      puts "Called with arguments: #{cli_arguments.inspect}"
      puts "and switches: #{config.inspect}"
    end

    if command == "export" && config[:format] == "excel"
      Kor::Export::Excel.new(cli_arguments.shift, config).run
    end

    if command == "import" && config[:format] == "excel"
      Kor::Import::Excel.new(cli_arguments.shift, config).run
    end
  end

  def command
    @command ||= cli_arguments.shift
  end

end