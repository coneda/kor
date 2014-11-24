class Kor::Config
  
  def initialize(*args)
    @config = {}
    update(args)
  end
  
  def self.load_config_file(file)
    result = load_file(file)
    (result['all'] || {}).deep_merge(result[Rails.env.to_s] || {})
  end
  
  def self.load_file(file)
    file = expand_path file
    File.exists?(file) ? YAML.load_file(file) || {} : {}
  end
  
  def self.expand_path(file)
    File.expand_path file, Rails.root
  end
  
  def store(file, env = Rails.env.to_s)
    file = Kor::Config.expand_path file

    old_state = if File.exists? file
      YAML.load_file(file) || {}
    else
      FileUtils.mkdir_p File.dirname(file)
      {}
    end
    
    d = YAML.dump(old_state.deep_merge(env => raw))
    File.open file, 'w' do |f|
      f.write d
    end
  end
  
  def update(config = nil)
    case config
      when String then raw.deep_merge! Kor::Config.load_config_file(config)
      when Kor::Config then raw.deep_merge! config.raw
      when Hash then raw.deep_merge! config
      when Array then config.each{|c| update(c)}
      when nil
        # do nothing
      else
        raise "#{config.inspect} is no valid config object: #{}"
    end
  end

  def raw
   @config
  end

  def [](name)
    result = @config
   
    Kor::Config.array_for(name).each do |key|
      if result.is_a?(Hash) && result.keys.include?(key)
        result = result[key]
      else
        return nil
      end
    end
    
    result
  end
  
  def []=(name, value)
    result = @config

    keys, last = Kor::Config.path_for(name)    
    keys.each do |key|
      result[key] = {} unless result.keys.include? key
      result = result[key]
    end
    
    result[last] = value
  end
  
  def clear(name)
    result = @config
   
    keys, last = Kor::Config.path_for(name)
    keys.each do |key|
      if result.keys.include? key
        result = result[key]
      else
        return nil
      end
    end
   
    result.delete(last)
  end
  
  def self.path_for(name)
    key_array = array_for(name)
    return key_array[0..-2], key_array.last
  end
  
  def self.name_for(name)
    case name
      when Symbol then name.to_s
      when Array then name.join('.')
      else
        name
    end
  end
  
  def self.human_section_name(section)
    I18n.t(section, :scope => "config.sections")
  end
  
  def self.human_attribute_name(attribute)
    I18n.t(attribute, :scope => "config.values")
  end
  
  def self.array_for(name)
    case name
      when Symbol then [name.to_s]
      when String then name.split('.')
      else
        name
    end
  end
  
end
