class Kor::ZipFile
  def initialize(filename, options = {})
    @filename = filename
    @options = options
    @files = {}
  end

  attr_reader :filename, :options

  def self.create(user_id, group_klass, group_id, entity_ids)
    group = group_klass.constantize.find(group_id)
    entities = Entity.find(entity_ids)

    zip_file = Kor::ZipFile.new("#{Rails.root}/tmp/download.zip",
      :user_id => user_id,
      :file_name => "#{group.name}.zip"
    )

    entities.each do |e|
      zip_file.add_entity e
    end

    zip_file
  end

  def self.create!(user_id, group_klass, group_id, entity_ids)
    zip_file = create(user_id, group_klass, group_id, entity_ids)
    zip_file.build notify: true
  end

  def build(opts = {})
    opts.reverse_merge! notify: false

    pack
    download = Download.create(
      :user_id => options[:user_id],
      :data => filename,
      :file_name => options[:file_name],
      :notify_user => opts[:notify]
    )
    destroy

    download
  end

  def add(source = nil, opts = {}, &block)
    if block_given?
      source = yield
    else
      source = File.absolute_path(source)
      opts[:as] ||= source.gsub Dir.pwd, ""
    end

    @files[opts[:as]] = source
  end

  def add_entity(entity)
    if entity.is_medium?
      if entity.medium.document.file?
        extention = entity.medium.original_extension
        add entity.medium.path(:original), :as => "#{entity.id}.#{extention}"
      else
        extention = entity.medium.style_extension(:normal)
        add entity.medium.path(:normal), :as => "#{entity.id}.#{extention}"
      end

      add nil, :as => "#{entity.id}.txt" do
        {:data => Kor::Export::MetaData.new(user).render(entity)}
      end
    end
  end

  def pack
    Dir.mktmpdir do |dir|
      system "mkdir -p #{dir}/kor_files"

      @files.each do |internal, external|
        file = "#{dir}/kor_files/#{internal}"
        run "mkdir -p #{File.dirname file}"

        case external
        when String then run "ln -s #{external} #{file}"
        when Hash
          File.open "#{file}", "w" do |f|
            f.write external[:data]
          end
        end
      end

      run "cd #{dir} && zip -r #{filename} kor_files > /dev/null"
    end
  end

  def destroy
    run "rm #{filename}"
  end

  def package_size
    @files.values.map do |f|
      case f
      when String then File.size(f)
      when Hash then f[:data].size
      end
    end.sum
  end

  def user
    User.find(options[:user_id])
  end

  def background?
    package_size.to_f / 1024 / 1024 > Kor.settings['max_foreground_group_download_size']
  end

  def run(command)
    system command
  end
end
