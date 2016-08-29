module ConfigHelper

  class ConfigScope
    def initialize(context, name)
      @context = context
      @name = Kor::Config.name_for(name)
    end
    
    def param(name)
      @name + '.' + Kor::Config.name_for(name)
    end
    
    def config_section(name)
      @context.config_section(param(name)) { yield ConfigScope.new(self, param(name)) }
    end
    
    def config_value(name, options = {})
      @context.config_value(param(name), options)
    end
  end
  
  def config_field_name_for(name, options = {})
    options.reverse_merge!(:multiple => false)
    'config' + Kor::Config.array_for(name).map{|k| "[#{k}]"}.join + (options[:multiple] ? '[]' : '')
  end
  
  def human_config_value_name(name)
    Kor::Config.human_attribute_name(Kor::Config.array_for(name).last)
  end
  
  def human_config_section_name(name)
    Kor::Config.human_section_name(Kor::Config.array_for(name).last).capitalize_first_letter
  end
    
  def config_section(name, &block)
    result = "<div class='form_subsection'>"
    result << content_tag('div', 
      link_to_function(human_config_section_name(name), "$('#{name}').toggle()"),
      :class => 'highlighted_subtitle'
    )
    
    result << "<div id='#{name}' class='sub_content' style='display: none'>"
    result << yield(ConfigScope.new(self, name))
    (result + "</div></div>").html_safe
  end
  
  def config_value(name, options = {})
    options.reverse_merge!(
      :type => :text_field,
      :field_name => config_field_name_for(name),
      :value => Kor.config[name],
      :translate => true,
      :capitalize => true
    )
  
    options[:label] ||= options[:translate] ? human_config_value_name(name) : name
    options[:label] = options[:label].capitalize_first_letter if options[:capitalize]

    options[:control] ||= case options[:type]
      when :check_box then check_box_tag(options[:field_name], options[:value], Kor.config(true)[name])
      when :text_area then text_area_tag(options[:field_name], options[:value])
      else
        text_field_tag(options[:field_name], options[:value])
    end
      
    kor_input_tag options[:label], options
  end
  
end
