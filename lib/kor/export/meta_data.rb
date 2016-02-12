class Kor::Export::MetaData
  
  def initialize(user)
    @user = user
    @profile = []
    Relation.primary_relation_names.each do |pr|
      @profile << {
        'name' => pr,
        'relations' => Relation.secondary_relation_names.map{|sr| {'name' => sr}}
      }
    end
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
      relationships = entity.outgoing_relationships.by_name(relation['name']).authorized_for(@user, :view)

      unless relationships.empty?
        result += line nil, relation['name'], options[:indent]
      end

      relationships.each do |relationship|
        result += render_entity(relationship.to,
          :properties => relationship.properties.join(', '),
          :profile => relation['relations'] || [],
          :indent => options[:indent] + 1
        )
      end
    end
    
    result
  end
  
end
