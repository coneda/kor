class Kor::Tasks
  def self.reprocess_all(config = {})
    num = Medium.count
    left = num
    started_at = nil
    puts "Found #{num} media entities"

    DelayedPaperclip::ProcessJob.with_adapter :inline do
      Medium.find_each do |m|
        started_at ||= Time.now

        m.image.reprocess! if m.image.file?
        m.document.reprocess! if m.document.file?

        left -= 1
        seconds_left = (Time.now - started_at).to_f / (num - left) * left
        puts "#{left} items left (ETA: #{Time.now + seconds_left.to_i})"
      end
    end
  end

  def self.index_all(config = {})
    Kor::Elastic.drop_index
    Kor::Elastic.create_index
    ActiveRecord::Base.logger.level = Logger::ERROR
    Kor::Elastic.index_all full: true, progress: true
  end

  def self.group_to_zip(config = {})
    klass = config[:class_name].constantize
    group_id = config[:group_id]
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

    response = unless config[:assume_yes]
      print "Continue [yes/no]? "
      $stdin.gets.strip
    end

    if config[:assume_yes] || response == "yes"
      zip_file = Kor::ZipFile.create(
        User.admin.id,
        group.class.name,
        group.id,
        group.entities.pluck(:id)
      )
      download = zip_file.build
      puts "Packaging complete, the zip file can be downloaded via"
      puts "#{Kor.root_url}/downloads/#{download.uuid}"
    end
  end

  def self.notify_expiring_users(config = {})
    opts = Kor.default_url_options
    ActionMailer::Base.default_url_options = opts

    users = User.where("expires_at < ? AND expires_at > ?", 2.weeks.from_now, Time.now)
    users.each do |user|
      UserMailer.upcoming_expiry(user).deliver_now
    end
    Rails.logger.info "Upcoming expiries: notified #{users.size} users"
  end

  def self.recheck_invalid_entities(config = {})
    group = SystemGroup.find_by_name('invalids')
    valids = group.entities.select do |entity|
      entity.valid?
    end

    puts "removing #{valids.count} from the 'invalids' system group"
    group.remove_entities valids
  end

  def self.delete_expired_downloads(config = {})
    Download.find(:all, conditions: ['created_at < ?', 2.weeks.ago]).each do |download|
      download.destroy
    end
  end

  def self.editor_stats(config = {})
    stats = Kor::Statistics::Editors.new(verbose: true)
    stats.run
    puts stats.report
  end

  def self.exif_stats(config = {})
    require "exifr"
    stats = Kor::Statistics::Exif.new(config[:from], config[:to],
      verbose: true
    )
    stats.run
    puts stats.report
  end

  def self.reset_admin_account(config = {})
    u = User.find_or_initialize_by name: 'admin'
    u.update!(
      groups: Credential.all,
      plain_password: 'admin',
      plain_password_confirmation: 'admin',
      terms_accepted: true,
      login_attempts: [],
      active: true,

      admin: true,
      relation_admin: true,
      authority_group_admin: true,
      kind_admin: true,

      full_name: u.full_name || I18n.t('users.administrator'),
      email: u.email || Kor.settings['maintainer_mail']
    )
  end

  def self.reset_guest_account(config = {})
    u = User.find_or_initialize_by name: 'guest'
    u.update!(
      terms_accepted: true,
      full_name: u.full_name || I18n.t('users.guest'),
      email: u.email || 'guest@example.com'
    )
  end

  def self.to_neo(config = {})
    require "ruby-progressbar"
    graph = Kor::NeoGraph.new(User.admin)

    graph.reset!
    graph.import_all
  end

  def self.connect_random(config = {})
    graph = Kor::NeoGraph.new(User.admin)
    graph.connect_random
  end

  def self.list_permissions(config = {})
    puts "Entities: "
    data = [['entity (id)', 'collection (id)'] + Kor::Auth.policies]
    Entity.by_id(config[:entity_id]).find_each do |entity|
      record = [
        "#{entity.name} (#{entity.id})",
        "#{entity.collection.name} (#{entity.collection.id})"
      ]

      Kor::Auth.policies.each do |policy|
        record << Kor::Auth.
          authorized_credentials(entity.collection, policy).
          map{ |c| c.name }.
          join(', ')
      end

      data << record
    end
    print_table data

    puts "\nUsers: "
    data = [['username (id)', 'credentials']]
    User.by_id(config[:user_id]).find_each do |user|
      data << ["#{user.name} (#{user.id})", user.groups.map{ |c| c.name }.join(', ')]
    end
    print_table data
  end

  def self.secrets(config = {})
    data = {}
    ['development', 'test', 'production'].each do |e|
      data[e] = {
        'secret_key_base' => Digest::SHA512.hexdigest("#{Time.now} #{rand}")
      }
    end

    File.open "#{Rails.root}/config/secrets.yml", 'w' do |f|
      f.write YAML.dump(data)
    end
  end

  def self.consistency_check(config = {})
    Relationship.includes(:relation, :from, :to).inconsistent.find_each do |r|
      puts [
        "#{r.id} #{r.from.display_name} [#{r.from_id}, #{r.from.kind.name}]".colorize(:blue),
        r.relation.name.colorize(:light_blue),
        "#{r.to.display_name} [#{r.to_id}, #{r.to.kind.name}]".colorize(:blue),
        'is unexpected, the relation expects:',
        Kind.find(r.relation.from_kind_id).name,
        '->',
        Kind.find(r.relation.to_kind_id).name
      ].join(' ')
    end
  end

  def self.import_erlangen_crm(config = {})
    Kor::Import::ErlangenCrm.new.run
  end

  def self.import_test_data(config = {})
    if User.count > 2 || Kind.count > 1 || Relation.count > 0
      puts "This installation is not empty, refusing to import test data"
    else
      require Rails.root.join('spec', 'support', 'data_helper').to_s
      DataHelper.default_setup
    end
  end

  def self.serve_api_docs(config = {})
    erb_file = "#{Rails.root}/docs/api.html.erb"
    intro_file = "#{Rails.root}/docs/api.intro.md"
    data_file = "#{Rails.root}/docs/api.yml"

    rebuild = true
    last_built_at = Time.now

    loop do
      if rebuild
        api_docs(config)
        rebuild = false
      end

      stat = [data_file, intro_file, erb_file].map{ |f| File.stat(f).mtime }.max

      if last_built_at < stat
        rebuild = true
        last_built_at = stat
      else
        sleep 0.2
      end
    end
  end

  def self.api_docs(config = {})
    erb_file = "#{Rails.root}/docs/api.html.erb"
    intro_file = "#{Rails.root}/docs/api.intro.md"
    data_file = "#{Rails.root}/docs/api.yml"

    puts "#{Time.now} building"
    intro = Kramdown::Document.new(File.read(intro_file)).to_html
    data = YAML.load_file(data_file)
    engine = ERB.new(File.read(erb_file), trim_mode: '-')
    html = engine.result(binding)

    File.open "#{Rails.root}/public/api.html", 'w' do |f|
      f.write html
    end
  rescue StandardError => e
    puts e.message
    puts e.backtrace
  end

  def self.flush(config = {})
    tables = [
      :authority_group_categories,
      :authority_groups,
      :authority_groups_entities,
      :delayed_jobs,
      :directed_relationships,
      :downloads,
      :entities,
      :entities_system_groups,
      :entities_tags,
      :entities_user_groups,
      :entity_datings,
      :fields,
      :generators,
      :identifiers,
      :kind_inheritances,
      :kinds,
      :media,
      :publishments,
      :relation_inheritances,
      :relations,
      :relationship_datings,
      :relationships,
      :taggings,
      :tags,
      :user_groups
    ]

    tables.each do |table|
      ActiveRecord::Base.connection.truncate(table)
    end

    Kind.create(
      name: Medium.model_name.human,
      plural_name: Medium.model_name.human(count: :other),
      uuid: Kind::MEDIA_UUID,
      settings: {
        naming: false
      }
    )

    system 'rm', '-rf', "#{ENV.fetch('DATA_DIR')}/media"
  end

  def self.print_table(data)
    maxes = {}
    data.each do |record|
      row = []
      record.each_with_index do |field, i|
        maxes[i] ||= data.map{ |r| r[i].to_s.size }.max
        row << "#{field.to_s.ljust(maxes[i])}"
      end
      puts "| #{row.join(' | ')} |"
    end
  end
end
