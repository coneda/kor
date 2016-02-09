class Kor::Export::MetaData
  
  def initialize(user, name)
    @user = user
    @profile = (Kor.config['meta_data_profiles'] || {})[name] || []
  end
  
  def line(name, value, indent = 0)
    indent_string = "  " * indent
    indent_string + (name ? "#{name}: #{value}\n" : "#{value}\n")
  end
  
  def render(entity)
    render_entity(entity)
  end
  
  def render_entity(entity, options = {})
    options.reverse_merge!(:profile => @profile, :indent => 0)
  
    result = ""
    if entity.is_medium?
      value = entity.uuid + (options[:properties].blank? ? "" : " (#{options[:properties]})")
      result += line Kind.medium_kind.name, value, options[:indent]
    else
      value = entity.display_name + (options[:properties].blank? ? "" : " (#{options[:properties]})")
      result += line nil, value, options[:indent]
    end
    
    options[:profile].each do |relation|
      blaze = Kor::Blaze.new(@user)
      relationships = blaze.relationship_scope(entity, :relation_names => relation['name'])
      
      unless relationships.empty?
        result += line nil, relation['name'], options[:indent]
      end
      
      relationships.each do |relationship|
        related_entity = relationship.other_entity(entity)
        result += render_entity(related_entity,
          :properties => relationship.properties.join(', '),
          :profile => relation['relations'] || [],
          :indent => options[:indent] + 1
        )
      end
    end
    
    result
  end
  
end
