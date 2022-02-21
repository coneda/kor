class Medium < ApplicationRecord
  has_one :entity

  def image
    @image ||= Kor::Storage.new(self, 'image',
      file_name: image_file_name,
      content_type: image_content_type,
      updated_at: image_updated_at
    )
  end

  def document
    @document ||= Kor::Storage.new(self, 'document',
      file_name: document_file_name,
      content_type: document_content_type,
      updated_at: document_updated_at
    )
  end

  def assign_file(attachment, new_file)
    file = new_file
    options = {}

    unless file
      attachment.assign_file(nil)
      return []
    end

    if new_file.is_a?(ActionDispatch::Http::UploadedFile)
      file = new_file.tempfile
      options[:content_type] = new_file.content_type
      options[:file_name] = new_file.original_filename
    else
      options[:content_type] = Kor::Storage.guess_content_type(file.path)
      options[:file_name] = file.path.split('/').last
    end

    options[:updated_at] = Time.now.utc.to_i

    attachment.assign_file(file, options)

    return [
      options[:content_type],
      options[:file_name],
      file.size,
      options[:updated_at]
    ]
  end

  def image=(new_file)
    content_type, file_name, size, time = assign_file(image, new_file)

    self.image_content_type = content_type
    self.image_file_name = file_name
    self.image_file_size = size
    self.image_updated_at = time
  end

  def document=(new_file)
    content_type, file_name, size, time = assign_file(document, new_file)

    self.document_content_type = content_type
    self.document_file_name = file_name
    self.document_file_size = size
    self.document_updated_at = time
  end

  # has_attached_file :document,
  #   path: "#{ENV['DATA_DIR']}/media/:style/:id_partition/document.:style_extension",
  #   url: "/media/images/:style/:id_partition/document.:style_extension",
  #   default_url: "/media/images/:style/:id_partition/image.:style_extension?:style_timestamp",
  #   styles: lambda{ |attachment| attachment.instance.custom_styles },
  #   processors: lambda{ |instance| instance.processors }

  # has_attached_file :image,
  #   :path => "#{ENV['DATA_DIR']}/media/:style/:id_partition/image.:style_extension",
  #   :url => "/media/images/:style/:id_partition/image.:style_extension",
  #   :default_url => lambda{ |attachment| attachment.instance.dummy_url },
  #   :convert_options => {:all => "+profile '*'"},
  #   :styles => {
  #     :icon => ['80x80>', :jpg],
  #     :thumbnail => ['140x140>', :jpg],
  #     :preview => ['300x300>', :jpg],
  #     :screen => ['800x800>', :jpg],
  #     :normal => ['1440x1440>', :jpg]
  #   }

  # process_in_background :document
  # process_in_background :image

  # def document=(value)
  #   document.assign(value)

  #   if value
  #     ct = MIME::Types.type_for(document.original_filename).first
  #     self.document_content_type = ct.to_s if ct
  #   end
  # end

  # TODO: do we still need this?
  # def custom_styles
  #   result = {}

  #   if document.present?
  #     ct = document.content_type
  #     if ct.match(/^(video\/|application\/x-shockwave-flash|application\/mp4)/)
  #       result.merge!(
  #         mp4: {format: :mp4, content_type: 'video/mp4'},
  #         ogg: {format: :ogv, content_type: 'video/ogg'},
  #         webm: {format: :webm, content_type: 'video/webm'}
  #       )
  #     end
  #     if ct.match(/^audio\//)
  #       result.merge!(
  #         mp3: {format: :mp3, content_type: 'audio/mp3'},
  #         ogg: {format: :ogg, content_type: 'audio/ogg'}
  #       )
  #     end
  #   end

  #   result
  # end

  # def processors
  #   if document.present?
  #     ct = document.content_type
  #     return [:video] if ct.match(/^(video\/|application\/x-shockwave-flash|application\/mp4)/)
  #     return [:audio] if ct.match(/^audio\//)
  #   end

  #   []
  # end

  def video?
    ct = document.content_type
    ct && !!ct.match(/^(video\/|application\/x-shockwave-flash|application\/mp4)/)
  end

  def audio?
    ct = document.content_type
    ct && !!document.content_type.match(/^audio\//)
  end

  # TODO: fix for audio case or remove if not used
  def presentable?
    self.content_type.match(/^(image|video|application\/x-shockwave-flash|application\/mp4)/)
  end

  def document_to_image
    @image = @document
    @image.attachment = 'image'

    self.image_file_name = document_file_name
    self.image_content_type = document_content_type
    self.image_file_size = document_file_size
    self.image_updated_at = document_updated_at

    @document = nil
    self.document_file_name = nil
    self.document_content_type = nil
    self.document_file_size = nil
    self.document_updated_at = nil
  end

  before_validation do |m|
    if m.document.file? && m.document.content_type.match(/^image\//) && !m.image.file?
      m.document_to_image
    end

    if file = (m.to_file || m.to_file(:image))
      m.datahash = Digest::SHA1.hexdigest(file.read)
    end
  end

  after_save do |m|
    m.image.save
    m.document.save

    if m.attachments_changed?
      m.rebuild_variants
    end
  end

  def rebuild_variants(later: false)
    if later
      ProcessVariantsJob.perform_later(id)
      return
    end

    document.rebuild_variants
    image.rebuild_variants
  end

  after_destroy do |m|
    m.image.clear
    m.image.save
    m.document.clear
    m.document.save
  end

  # validates :image, content_type: {content_type: /^image\/.+$/, if: Proc.new{ |medium| medium.image.file? }}
  # validates :document, attachment_presence: {unless: Proc.new{ |medium| medium.image.file? }, message: :file_must_be_set}
  validates :datahash, uniqueness: {:message => :file_exists}

  validate :validate_content_type
  validate :validate_document_presence
  validate :validate_no_two_images
  validate :validate_file_size

  def validate_content_type
    if image.file?
      unless image.content_type.match?(/^image\/.+$/)
        errors[:image] << :invalid_content_type
      end
    end
  end

  def validate_document_presence
    if !image.file? && !document.file?
      errors[:document] << :file_must_be_set
    end
  end

  def validate_no_two_images
    invalid = document.content_type &&
      image.content_type && 
      (
        document.content_type.match(/^image\//) && 
        image.content_type.match(/^image\//)
      )
      
    if invalid
      errors.add :base, :no_two_images
    end
  end

  def validate_file_size
    max_mb = Kor.settings['max_file_upload_size'].to_f
    max_bytes = max_mb * 1024**2

    if image_file_size.present? and image_file_size > max_bytes
      errors.add :image_file_size, :file_size_less_than, :value => max_mb
    end

    if document_file_size.present? and document_file_size > max_bytes
      errors.add :document_file_size, :file_size_less_than, :value => max_mb
    end
  end

  def to_file(attachment = :document, style = :original)
    path = if attachment == :document
      # document.staged_path || document.path
      document.variant_file(style.to_s)
    else
      # image.staged_path || image.path(style)
      image.variant_file(style.to_s)
    end

    if path && File.exist?(path)
      File.open(path)
    end
  end

  def file_size
    document_file_size || image_file_size
  end

  def content_type(style = :original)
    result = if style == :original
      document.content_type || image.content_type
    elsif image_style?(style)
      "image/jpg"
    else
      custom_styles[style.to_sym][:content_type]
    end

    result.is_a?(String) ? result.downcase : 'application/octet-stream'
  end

  def image?
    document.file? ? document.image? : image.image?
  end

  def video?
    document.video?
  end

  def audio?
    document.audio?
  end

  def data_file(style = :original)
    if style == :original
      document.file? ? to_file(:document, style) : to_file(:image, style)
    elsif image_style?(style)
      File.open path(style)
    else
      custom_style_file(style)
    end
  end

  def data(style = :original, options = {})
    options.reverse_merge! range: nil
    self.class.read_range data_file(style), options[:range]
  end

  def size(style = :original)
    data_file(style).size
  end

  def original
    document.file? ? document : image
  end

  def original_extension
    if original.original_filename
      File.extname(original.original_filename).gsub('.', '').downcase
    else
      # dummy
      'tif'
    end
  end

  def style_extension(style = :original)
    attachment_for(style.to_s).class::VARIANTS[style.to_s][:extension]
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
      "#{entity.id}.#{style}.#{custom_styles[style.to_sym][:file_extension]}"
    end
  end

  def ids
    ("%09d" % id).scan(/\d{3}/).join('/')
  end

  def custom_style_path(style)
    document.path(style.to_sym)
  end

  def custom_style_url(style)
    document.url(style.to_sym)
  end

  def custom_style_file(style)
    File.open custom_style_path(style.to_sym)
  end

  def image_style?(style)
    image.class::VARIANTS.keys.include? style.to_s
  end

  def attachments_changed?
    saved_change_to_document_updated_at ||
    saved_change_to_image_updated_at
  end

  def attachment_for(style)
    image_styles = ['normal', 'screen', 'preview', 'thumbnail', 'icon', 'still']
    return image if image_styles.include?(style.to_s)
    return image if !document.file? && style == :original
    return document
  end

  def url(style = :original, disposition = 'inline')
    return dummy_url if Rails.env.development? && !ENV['SHOW_MEDIA']

    disposition = 'images' if disposition == 'inline'
    a = attachment_for(style)
    File.exists?(a.variant_path(style.to_s)) ?
      a.variant_url(style.to_s, disposition) :
      dummy_url
  end

  def path(style = :original)
    path = attachment_for(style).variant_path(style.to_s)
    File.exist?(path) ? path : dummy_path
  end

  def dummy_path
    self.class.dummy_path(content_type)
  end

  def self.dummy_path(content_type)
    "#{Rails.root}/public#{self.dummy_url content_type}"
  end

  def dummy_url
    self.class.dummy_url(content_type)
  end

  def self.dummy_url(content_type)
    group, type = content_type.split('/').map{ |t| t.gsub(/\//, '_') }

    dir = "#{Rails.root}/public/content_types"
    group_dir = "#{dir}/#{group}"

    if File.exist?("#{group_dir}/#{type}.gif")
      "/content_types/#{group}/#{type}.gif"
    elsif File.exist?("#{group_dir}.gif")
      "/content_types/#{group}.gif"
    else
      "/content_types/default.gif"
    end
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

  def human_content_type
    group, type = content_type.split('/')
    I18n.t(type, :scope => ['mimes', group], :default => content_type)
  end

  def self.read_range(file, range = nil)
    if range
      file.seek range[0]
      file.read range[0] + range[1] + 1
    else
      file.read
    end
  end

  def self.mime_counts
    result = Medium.group(:image_content_type).count.
      merge(Medium.group(:document_content_type).count)
    result.delete nil
    result
  end
end
