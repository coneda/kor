Paperclip.interpolates :style_extension do |attachment, style|
  if attachment.name == :document
    if style == :original
      attachment.instance.original_extension
    else
      attachment.instance.style_extension(style)
    end
  else
    style == :original ? File.extname(attachment.original_filename).gsub('.', '') : 'jpg'
  end
end

Paperclip.interpolates :style_timestamp do |attachment, style|
  if attachment.file?
    attachment.updated_at.to_i
  else
    attachment.instance.image.updated_at.to_i
  end
end

module Paperclip::Interpolations
  def id_partition attachment, style_name
    case id = attachment.instance.id
    when Integer
      ("%09d" % id).scan(/\d{3}/).join("/")
    when String
      id.scan(/.{3}/).first(3).join("/")
    else
      nil
    end
  end
end

