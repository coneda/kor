class Api::Renderers::Base

  def render(object, options = {})
    xml(options).response do
      render_object object, options
    end
  end
  
  def render_object(object, options = {})
    if object.class == Entity
      xml_for_entity object, options
    elsif object.class == String
      xml.message object
    elsif object.class == Array
      object.each do |o|
        render_object o, options
      end
    elsif object.class == ActiveRecord::NamedScope::Scope
      render_object object.to_a, options
    else
      object.to_xml options
    end
  end
  
  def xml(options = {})
    options.reverse_merge!(:indent => 2)
  
    if not @builder or options[:force]
      @builder = ::Builder::XmlMarkup.new(options)
      @builder.instruct! if options[:instruct]
    end
    
    @builder
  end
  
  def xml_for_entity(entity, options = {})
    options.reverse_merge!(
      :external_references => false,
      :dataset => false,
      :properties => false,
      :synonyms => false,
      :datings => false,
      :relationships => false
    )
  
    xml.entity do
      xml.uuid entity.uuid
      xml.name entity.name
      xml.distinct_name entity.distinct_name      
      xml.kind_name entity.kind_name
      xml.subtype entity.subtype
      xml.comment
      xml.created_at entity.created_at
      xml.updated_at entity.updated_at
      
      if options[:dataset]
        xml.dataset do
          entity.kind.field_instances(entity).each do |field|
            xml.tag! field.name, field.value
          end
        end
      end
      
      if options[:properties]
        xml.properties do
          entity.properties.each do |label, value|
            xml.property do
              xml.label label
              xml.value value
            end
          end
        end
      end
      
      if options[:synonyms]
        xml.synonyms do
          entity.synonyms.each do |s|
            xml.synonym s
          end
        end
      end
      
      if options[:datings]
        xml.datings do
          entity.datings.each do |d|
            xml.dating do
              xml.label d.label
              xml.dating_string d.dating_string
            end
          end
        end
      end
      
      if options[:external_references]
        xml.external_references do
          entity.external_references.each do |k, v|
            xml.reference do
              xml.label k
              xml.id v
            end
          end
        end
      end
      
      if options[:relationships]
        xml.relationships do
          entity.relationships.grouped.each do |k, v|
            xml.relation do
              xml.name k
              xml.id v.first.relation_id
              xml.entities do
                v.each do |e|
                  xml.uuid e.other_entity(entity).uuid
                end
              end
            end
          end
        end
      end
    end
    
  end
  
end
