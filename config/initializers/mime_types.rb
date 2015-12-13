# Be sure to restart your server when you modify this file.

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf
# Mime::Type.register_alias "text/html", :iphone
# Mime::Type.register "text/html", :mobile

# required for paperclip to make it accept the .image file extension
["image/tiff", "image/jpeg", "image/png", "image/gif", "image/vnd.adobe.photoshop"].each do |mtn|
  if mt = MIME::Types[mtn].first
    mt.add_extensions "image"
    # mt.extensions << "image"
    # MIME::Types.send :index_extensions, mt
  else
    puts mtn
  end
end
