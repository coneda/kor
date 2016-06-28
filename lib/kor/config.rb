require 'yaml'

module Kor
  class Config

    def self.env
      ENV['RAILS_ENV'] || 'development'
    end

    def self.rails_root
      File.expand_path(File.dirname(__FILE__) + '/../..')
    end

    def self.config_root
      "#{rails_root}/config"
    end

    def self.env_part
      env == 'production' ? '' : "#{env}."
    end

    def self.default_config_file
      "#{config_root}/kor.defaults.yml"
    end
    
    def self.config_file
      "#{config_root}/kor.yml"
    end
    
    def self.app_config_file
      "#{config_root}/kor.app.#{env_part}yml"
    end

    def self.instance
      if @instance.blank? || env == 'development'
        reload!
      end

      @instance
    end

    def self.reload!
      @instance = new(default_config_file, config_file, app_config_file)
    end

    def initialize(*args)
      @config = {}
      update(args)
    end
    
    def self.load_config_file(file)
      result = load_file(file)
      deep_merge (result['all'] || {}), (result[env.to_s] || {})
    end
    
    def self.load_file(file)
      file = expand_path file
      File.exists?(file) ? YAML.load_file(file) || {} : {}
    end
    
    def self.expand_path(file)
      File.expand_path file, rails_root
    end
    
    def store(file, env = nil)
      env = self.class.env if env == nil
      file = self.class.expand_path file

      old_state = if File.exists? file
        YAML.load_file(file) || {}
      else
        FileUtils.mkdir_p File.dirname(file)
        {}
      end

      data = self.class.deep_merge(old_state, env => @config)
      data = self.class.remove_indifferent_access(data)
      data = YAML.dump(data)
      File.open file, 'w' do |f|
        f.write data
      end
    end
    
    def update(config = nil)
      case config
        when String
          @config = self.class.deep_merge @config, self.class.load_config_file(config)
        when self.class
          @config = self.class.deep_merge @config, config.raw
        when Hash
          @config = self.class.deep_merge @config, config
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
     
      self.class.array_for(name).each do |key|
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

      keys, last = self.class.path_for(name)    
      keys.each do |key|
        result[key] = {} unless result.keys.include? key
        result = result[key]
      end
      
      result[last] = value
    end
    
    def clear(name)
      result = @config
     
      keys, last = self.class.path_for(name)
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

    def self.deep_merge(first, second)
      return first if second.nil?
      merger = proc { |key, v1, v2| Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : v2 }
      first.merge(second, &merger)
    end

    def self.remove_indifferent_access(ia)
      result = ia.to_hash
      result.each do |key, value|
        if value.is_a?(HashWithIndifferentAccess) || value.is_a?(Hash)
          result[key] = self.remove_indifferent_access(value)
        end
      end
      result
    end

  end
end
