class Api::Renderers::ChecksumRenderer < Api::Renderers::Base
  
  def render_object(object, options = {})
    if object.class == Entity
      xml.entity do
        xml.uuid object.uuid
        xml.checksum object.medium.datahash
      end
    elsif object.class == Array
      object.each do |o|
        render_object o, options
      end
    elsif object.class == ActiveRecord::NamedScope::Scope
      render_object object.to_a, options
    end
  end
  
end
