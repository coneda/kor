class Medium < ActiveRecord::Base

  DelayedPaperclip::Railtie.insert
  
  has_one :entity

  # -------------------------------------------------------------- paperclip ---
  def self.media_data_dir
    if Rails.env == 'production'
      "#{Rails.root}/data/media"
    else
      "#{Rails.root}/data/media.#{Rails.env}"
    end
  end
  
  has_attached_file :document, 
    :path => "#{media_data_dir}/:style/:id_partition/document.:style_extension",
    :url => "/media/images/:style/:id_partition/document.:style_extension",
    :default_url => "/media/images/:style/:id_partition/image.:style_extension?:style_timestamp",
    :styles => {:flash => {:format => :flv}},
    :processors => Proc.new{ |a|
      is_video = a.content_type.match(/^(video|application\/x-shockwave-flash)/)
      is_video ? [:video] : [:empty]
    }
    
  has_attached_file :image,
    :path => "#{media_data_dir}/:style/:id_partition/image.:style_extension",
    :url => "/media/images/:style/:id_partition/image.:style_extension",
    :default_url => "/content_types/:medium_content_type.gif",
    :styles => {
      :icon => ['80x80>', :jpg],
      :thumbnail => ['140x140>', :jpg],
      :preview => ['300x300>', :jpg],
      :screen => ['800x800>', :jpg],
      :normal => ['1440x1440>', :jpg]
    }

  process_in_background :document  
  process_in_background :image

  before_validation do |m|
    if m.document.to_file
      m.document.instance_write :content_type, `file --mime-type -b #{m.document.to_file.path}`.strip.split(';').first
    end
  end
  
  def serializable_hash(*args)
    {
      :id => id,
      :url => image.url(:preview),
      :file_size => file_size,
      :content_type => content_type
    }
  end

  def presentable?
    self.content_type.match /^(image|video|application\/x-shockwave-flash)/
  end
  
  def custom_styles
    {
      :flash => {:file_extension => 'flv', :content_type => 'video/x-flv'}
    }
  end
  
  def kind
    Kind.medium_kind
  end
  
  before_validation do |m|
    if m.document.file? && m.document.content_type.match(/^image\//)
      unless m.image.file?
        m.image = m.document
        m.document.clear
      end
    end
    
    m.datahash = Digest::SHA1.hexdigest(File.read(m.to_file.path)) if m.to_file
  end
  
  after_destroy do |medium|
    medium.custom_styles.each do |name, config|
      file = medium.custom_style_path(name)
      FileUtils.rm(file) if File.exists?(file)
    end
  end
  
  
  # Validation

  validates_attachment_content_type :image, :content_type => /^image\/.+$/, :if => Proc.new{|medium| medium.image.file?}
  validates_attachment_presence :document, :unless => Proc.new{|medium| medium.image.file?}, :message => :file_must_be_set
  validates_uniqueness_of :datahash, :message => :file_exists
  validate :validate_no_two_images
  validate :validate_file_size
  
  def validate_no_two_images
    if document.content_type && image.content_type
      if document.content_type.match(/^image\//) && image.content_type.match(/^image\//)
        errors.add :base, :no_two_images
      end
    end
  end

  def validate_file_size
    max_mb = Kor.config["app.max_file_upload_size"].to_f
    max_bytes = max_mb * 1024**2

    if image_file_size.present? and image_file_size > max_bytes
      errors.add :image_file_size, :file_size_less_than, :value => max_mb
    end

    if document_file_size.present? and document_file_size > max_bytes
      errors.add :document_file_size, :file_size_less_than, :value => max_mb
    end
  end
  
  
  # Paperclip
  
  def to_file
    document.to_file || image.to_file
  end

  def content_type(style = :original)
    if style == :original
      document.content_type || image.content_type
    elsif image_style?(style)
      "image/jpg"
    else
      custom_styles[style][:content_type]
    end.downcase
  end
  
  def file_size
    original.size
  end
  
  def data(style = :original)
    if style == :original
      document.file? ? document.to_file(style).read : image.to_file(style).read
    elsif image_style?(style)
      File.read path(style)
    else
      custom_style_data(style)
    end
  end
  
  def original
    document.file? ? document : image
  end
  
  def original_extension
    File.extname(original.original_filename).gsub('.', '').downcase
  end
  
  def style_extension(style = :original)
    (document.styles[style] || image.styles[style] || {})[:format]
  end
  
  def download_filename(style = :original)
    if style == :original
      a, b = content_type.split('/')
      if a == 'image'
        "#{entity.id}.#{style}.#{b}"
      else
        "#{entity.id}.#{style}.#{original_extension}"
      end
    elsif image_style?(style)
      "#{entity.id}.#{style}.#{style_extension(style)}"
    else
      "#{entity.id}.#{style}.#{custom_styles[style][:file_extension]}"
    end
  end
  
  def ids
    ("%09d" % id).scan(/\d{3}/).join('/')
  end
  
  def custom_style_path(style)
    "#{self.class.media_data_dir}/#{style}/#{ids}/document.#{custom_styles[style][:file_extension]}"
  end
  
  def custom_style_url(style)
    "/media/images/#{style}/#{ids}/document.#{custom_styles[style][:file_extension]}?#{document.updated_at}"
  end
  
  def custom_style_data(style)
    File.read custom_style_path(style)
  end
  
  def image_style?(style)
    image.styles.keys.include? style
  end
  
  def url(style = :original)
    if style == :original
      document.url(:original)
    elsif image_style?(style)
      image.url(style)
    else
      custom_style_url(style)
    end
#  rescue => e
#    debugger
#    image.options[:default_url].gsub ":medium_content_type", content_type
  end
  
  def path(style = :original)
    if style == :original
      document.path(:original) || image.path(:original)
    elsif image_style?(style)
      (image.path(style) && File.exists?(image.path(style))) ? image.path(style) : self.class.dummy_path(content_type)
    else
      custom_style_path(style)
    end
  end
  
  def self.dummy_data(content_type)
    File.read dummy_path(content_type)
  end
  
  def self.dummy_path(content_type)
    group, type = content_type.split('/')
  
    dir = "#{Rails.root}/public/content_types"
    group_dir = "#{dir}/#{group}"
    dummy = "#{group_dir}/#{type}.gif"
    
    unless File.exists? dummy
      FileUtils.mkdir_p group_dir
      
      if File.exists? "#{group_dir}.gif"
        FileUtils.ln_sf "../#{group}.gif", dummy
      else
        FileUtils.ln_sf "../default.gif", dummy
      end
    end
    
    dummy
  end
  
  def uri=(value)
    self[:original_url] = value
    
    u = URI.parse value
    case u
      when URI::Generic
        if u.scheme == 'file'
          self.document = File.open(u.path)
        else
          raise "The file scheme is the only allowed generic scheme"
        end
      else
        self.document = u
    end
  end

  def original_url=(value)
    unless value.blank?
      self [:original_url] = value
      self.document = open URI(value)
    end
  end
  
  def human_content_type
    group, type = content_type.split('/')
    I18n.t(type, :scope => ['mimes', group], :default => content_type)
  end

  def document=(value)
    attachment_for(:document).assign(value)

    if value
      ct = MIME::Types.type_for(value.original_filename).first
      self.document_content_type = ct.to_s if ct
    end
  end
  
end
