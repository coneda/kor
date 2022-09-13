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

Paperclip.interpolates :style_timestamp do |attachment, _style|
  if attachment.file?
    attachment.updated_at.to_i
  else
    attachment.instance.image.updated_at.to_i
  end
end

# prevent paperclip's file spoofing checks
module Paperclip
  class MediaTypeSpoofDetector
    def spoofed?
      false
    end
  end
end

module Paperclip::Interpolations
  def id_partition(attachment, style_name)
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

# so we can change the adapter for image transformations to :inline
require 'delayed_paperclip/process_job'
class DelayedPaperclip::ProcessJob
  def self.with_adapter(adapter, &block)
    old = self.queue_adapter
    self.queue_adapter = adapter
    yield
  ensure
    self.queue_adapter = old
  end
end

# suppress URI.escape "obsolete" warnings
require 'paperclip/url_generator'
class Paperclip::UrlGenerator
  def escape_url(url)
    if url.respond_to?(:escape)
      url.escape
    else
      URI::DEFAULT_PARSER.escape(url).gsub(escape_regex) do |m|
        "%#{m.ord.to_s(16).upcase}"
      end
    end
  end
end
