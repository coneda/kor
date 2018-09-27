class Download < ActiveRecord::Base
  
  # Associations
  
  belongs_to :user
  
  
  # Validations

  validates :user, :uuid, :content_type, :file_name, :new_data, presence: true
  
  
  # Callbacks

  before_validation(:on => :create) do |model|
    model.generate_uuid
    model.copy_file
    model.guess_content_type
  end
  after_create :notify_ready
  after_destroy :delete_files
  
  # handling
  
  def copy_file
    unless File.exists?(dir)
      system "mkdir -p #{dir}"
    end

    case new_data
      when File then FileUtils.copy(new_data.path, path)
      when String
        if File.exists?(new_data)
          system "cp", new_data, path
        else
          File.open path, "w" do |f|
            f.write new_data
          end
        end
    end
  end
  
  def notify_ready
    UserMailer.download_ready(self).deliver_now if notify_user
  end
  
  def generate_uuid
    self[:uuid] ||= SecureRandom.uuid
  end
  
  def guess_content_type
    self[:content_type] ||= `file -ib #{path}`.gsub(/\n/,"")
  end
  
  def delete_files
    FileUtils.rm_f(path)
  end
  
  
  # Accessors
  
  attr_accessor :notify_user
  
  # def link
  #   "#{Kor.base_url}/downloads/#{uuid}"
  # end
  
  def data=(value)
    @data = value
  end
  
  def new_data
    @data
  end
  
  def data
    File.read(path)
  end
  
  def path
    "#{dir}/#{uuid}"
  end
  
  def dir
    "#{Rails.root}/data/downloads"
  end

end
