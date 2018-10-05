# require 'yaml'

module Kor
  class Settings

    attr_reader :errors

    def initialize
      @attributes = {}
      @errors = []
      load
    end

    def self.instance(options = {})
      if @instance.blank? || options[:force_reload]
        @instance = new
      end

      @instance
    end

    def [](key)
      @attributes.has_key?(key) ?
      @attributes[key] :
      defaults[key]
    end

    def []=(key, value)
      update key => value
    end

    def fetch(key)
      unless self[key]
        update key => yield
      end

      self[key]
    end

    # TODO: don't save values if they are the same as the defaults
    def update(values)
      @attributes.merge! values
      process
      save
    end

    def save
      persist if valid?
    end

    def valid?
      true
    end

    def persist
      self.class.with_lock do
        if stale?
          @errors << I18n.t('activerecord.errors.messages.stale_config_update')
          false
        else
          File.open filename, 'w' do |f|
            @attributes['version'] = self['version'] + 1
            f.write @attributes.to_json
          end

          true
        end
      end
    end

    def load
      self.class.with_lock do
        if File.exists?(filename)
          File.open filename, 'r' do |f|
            @attributes = JSON.parse(f.read)
          end
        else
          @attributes = {}
        end
      end
    end

    def stale?
      if File.exists?(filename)
        file_version = JSON.parse(File.read filename)['version']
        if file_version
          file_version > self['version'].to_i
        end
      end
    end

    def ensure_fresh
      load
    end

    def self.purge_files!
      FileUtils.rm_f filename
      FileUtils.rm_f lockfile
    end

    def as_json
      return {
        'values' => defaults.merge(@attributes),
        'defaults' => defaults,
      }
    end

    def defaults
      self.class.defaults
    end

    protected

      def process
        @attributes['welcome_html'] = self.class.markdown(self['welcome_text'])
        @attributes['legal_html'] = self.class.markdown(self['legal_text'])
        @attributes['about_html'] = self.class.markdown(self['about_text'])

        integers = [
          'current_history_length', 'max_foreground_group_download_size',
          'max_file_upload_size', 'max_results_per_request',
          'max_included_results_per_result', 'session_lifetime',
          'publishment_lifetime', 'max_download_group_size'
        ]
        integers.each do |i|
          @attributes[i] = self[i].to_i
        end

        integer_arrays = [
          'default_groups', 'primary_relations', 'secondary_relations'
        ]
        integer_arrays.each do |ia|
          @attributes[ia] = self[ia].map{|i| i.to_i}
        end
      end

      def self.markdown(text)
        RedCloth.new(text).to_html
      end

      def self.defaults
        return {
          'version' => 1,

          'default_locale' => 'en',
          'welcome_title' => 'Welcome to ConedaKOR',
          'welcome_text' => 'This text can be configured in the settings',
          'current_history_length' => 5,
          'max_foreground_group_download_size' => 10,
          'max_file_upload_size' => 100,
          'max_results_per_request' => 500,
          'max_included_results_per_result' => 4,
          'sources_release' => 'https://github.com/coneda/kor/releases/tag/v{{version}}',
          'sources_pre_release' => 'https://github.com/coneda/kor/commit/{{commit}}',
          'sources_default' => 'https://github.com/coneda/kor',

          'maintainer_name' => 'Example Organization',
          'maintainer_mail' => 'admin@example.com',
          'legal_text' => 'enter a legal notice here',
          'about_text' => 'enter a description of this installation here',
          
          'session_lifetime' => 60 * 60 * 2,
          'publishment_lifetime' => 14,
          'default_groups' => [],
          'env_auth_button_label' => 'federated login',
          'fail_on_update_errors' => true,

          'custom_css_file' => 'data/custom.css',

          'kind_dating_label' => 'Dating',
          'kind_name_label' => 'Name',
          'kind_distinct_name_label' => 'Distinct Name',

          'relationship_dating_label' => 'Dating',

          'max_download_group_size' => 80,

          'search_entity_name' => 'Name / Title / UUID',

          'primary_relations' => [],
          'secondary_relations' => [],

          'repository_uuid' => nil
        }
      end


  # host:
  #   protocol: http
  #   host: example.com
  #   port: 80

  # app:
  #   default_locale: "en"
  #   welcome_title: "Welcome to ConedaKOR"
  #   welcome_text: "This text can be configured in the general settings"
  #   current_history_length: 5
  #   max_foreground_group_download_size: 10
  #   max_file_upload_size: "100"
  #   max_results_per_request: 500
  #   max_included_results_per_result: 4

  #   sources:
  #     release: "https://github.com/coneda/kor/releases/tag/v{{version}}"
  #     pre_release: "https://github.com/coneda/kor/commit/{{commit}}"
  #     default: "https://github.com/coneda/kor"

  # maintainer:
  #   name: Example Organization
  #   mail: admin@example.com
  #   legal_text: Beispieltext
  #   about_text: Beispieltext

  # auth:
  #   session_lifetime: 2:00:00
  #   publishment_lifetime: 14
  #   # TODO: test this
  #   default_groups: []
  #   env_auth_button_label: "federated login"
  #   fail_on_update_errors: true

  # google_analytics:
  #   id: "12345"

  # piwik:
  #   url: "https://analytics.example.com"
  #   id: "1"

  # custom_css_file: data/custom.css

  # kind_settings:
  #   defaults:
  #     dating_label: Dating
  #     name_label: Name
  #     distinct_name_label: distinct Name

  # limits:
  #   max_file_upload_size: 30
  #   max_download_group_size: 80

  # search:
  #   entity_name: "Name / Titel / UUID"

  # CORS: set the hosts that are allowed to make AJAX requests to this instance
  # allowed_origins: ['localhost:8000']

  # mail:
  #   delivery_method: test

# production:
#   mail:
#     delivery_method: smtp
#     smtp_settings:
#       host: 127.0.0.1
#       port: 25
#       enable_starttls_auto: false
#       # domain: localhost

# test:
#   auth:
#     sources:
#       remote_user:
#         type: 'env'
#         user: ['REMOTE_USER']
#         domain: ['example.com']
#         mail: ['mail']
#         full_name: ['full_name']
#         splitter: '[,;]+'
#         map_to: 'ldap'
#       credentials_via_file:
#         type: script
#         script: spec/fixtures/auth_script.file
#         map_to: ldap
#       credentials_via_env:
#         script: spec/fixtures/auth_script.direct
#         map_to: ldap

  # app:
  #   gallery:
  #     primary_relations: ['shows']
  #     secondary_relations: ['has been created by']

      def filename
        self.class.filename
      end

      def self.filename
        file = {
          'production' => 'settings.json',
          'development' => 'settings.development.json',
          'test' => 'settings.test.json'
        }[Rails.env.to_s]
        Rails.root.join('data', file)
      end

      def self.lockfile
        "#{filename}.lock"
      end

      def self.with_lock
        File.open lockfile, File::RDWR | File::CREAT do |f|
          f.flock File::LOCK_EX
          yield
        end
      end


    # def self.env
    #   Rails.env.to_s
    # end

    # def self.rails_root
    #   File.expand_path(File.dirname(__FILE__) + '/../..')
    # end

    # def self.config_root
    #   "#{rails_root}/config"
    # end

    # def self.env_part
    #   env == 'production' ? '' : "#{env}."
    # end

    # def self.default_config_file
    #   "#{config_root}/kor.defaults.yml"
    # end
    
    # def self.config_file
    #   "#{config_root}/kor.yml"
    # end
    
    # def self.app_config_file
    #   "#{config_root}/kor.app.#{env_part}yml"
    # end

    # def self.reload!
    #   @instance = new(default_config_file, config_file, app_config_file)
    # end

    # def initialize(*args)
    #   @config = {}
    #   update(args)
    # end
    
    # def self.load_config_file(file)
    #   result = load_file(file)
    #   deep_merge (result['all'] || {}), (result[env.to_s] || {})
    # end
    
    # def self.load_file(file)
    #   file = expand_path file
    #   File.exists?(file) ? YAML.load_file(file) || {} : {}
    # end
    
    # def self.expand_path(file)
    #   File.expand_path file, rails_root
    # end
    
    # def store(file, env = nil)
    #   env = self.class.env if env == nil
    #   file = self.class.expand_path file

    #   old_state = if File.exists? file
    #     YAML.load_file(file) || {}
    #   else
    #     FileUtils.mkdir_p File.dirname(file)
    #     {}
    #   end

    #   data = self.class.deep_merge(old_state, env => @config)
    #   data = self.class.remove_indifferent_access(data)
    #   data = YAML.dump(data)
    #   File.open file, 'w' do |f|
    #     f.write data
    #   end
    # end
    
    # def update(config = nil)
    #   case config
    #     when String
    #       @config = self.class.deep_merge @config, self.class.load_config_file(config)
    #     when self.class
    #       @config = self.class.deep_merge @config, config.raw
    #     when Hash
    #       @config = self.class.deep_merge @config, config
    #     when Array then config.each{|c| update(c)}
    #     when nil
    #       # do nothing
    #     else
    #       raise "#{config.inspect} is no valid config object: #{}"
    #   end
    # end

    # def raw
    #  @config
    # end

    # def [](name)
    #   result = @config
     
    #   self.class.array_for(name).each do |key|
    #     if result.is_a?(Hash) && result.keys.include?(key)
    #       result = result[key]
    #     else
    #       return nil
    #     end
    #   end
      
    #   result
    # end
    
    # def []=(name, value)
    #   result = @config

    #   keys, last = self.class.path_for(name)    
    #   keys.each do |key|
    #     result[key] = {} unless result.keys.include? key
    #     result = result[key]
    #   end
      
    #   result[last] = value
    # end
    
    # def clear(name)
    #   result = @config
     
    #   keys, last = self.class.path_for(name)
    #   keys.each do |key|
    #     if result.keys.include? key
    #       result = result[key]
    #     else
    #       return nil
    #     end
    #   end
     
    #   result.delete(last)
    # end
    
    # def self.path_for(name)
    #   key_array = array_for(name)
    #   return key_array[0..-2], key_array.last
    # end
    
    # def self.name_for(name)
    #   case name
    #     when Symbol then name.to_s
    #     when Array then name.join('.')
    #     else
    #       name
    #   end
    # end
    
    # def self.human_section_name(section)
    #   I18n.t(section, :scope => "config.sections")
    # end
    
    # def self.human_attribute_name(attribute)
    #   I18n.t(attribute, :scope => "config.values")
    # end
    
    # def self.array_for(name)
    #   case name
    #     when Symbol then [name.to_s]
    #     when String then name.split('.')
    #     else
    #       name
    #   end
    # end

    # def self.deep_merge(first, second)
    #   return first if second.nil?
    #   merger = proc { |key, v1, v2| Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : v2 }
    #   first.merge(second, &merger)
    # end

    # def self.remove_indifferent_access(ia)
    #   result = ia.to_hash
    #   result.each do |key, value|
    #     if value.is_a?(HashWithIndifferentAccess) || value.is_a?(Hash)
    #       result[key] = self.remove_indifferent_access(value)
    #     end
    #   end
    #   result
    # end

  end
end
