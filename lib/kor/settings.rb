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
        if File.exist?(filename)
          File.open filename, 'r' do |f|
            @attributes = JSON.parse(f.read)
          end
        else
          @attributes = {}
        end
      end
    end

    def stale?
      if File.exist?(filename)
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

    def self.filename
      file = {
        'production' => 'settings.json',
        'development' => 'settings.development.json',
        'test' => 'settings.test.json'
      }[Rails.env.to_s]
      Rails.root.join(ENV['DATA_DIR'], file)
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

    protected

      def process
        @attributes['welcome_html'] = self.class.markdown(self['welcome_text'])
        @attributes['legal_html'] = self.class.markdown(self['legal_text'])
        @attributes['about_html'] = self.class.markdown(self['about_text'])

        integers = [
          'current_history_length', 'max_results_per_request',
          'max_included_results_per_result', 'session_lifetime',
          'publishment_lifetime'
        ]
        integers.each do |i|
          @attributes[i] = self[i].to_i
        end

        floats = [
          'max_download_group_size', 'max_foreground_group_download_size',
          'max_file_upload_size',
        ]
        floats.each do |i|
          @attributes[i] = self[i].to_f
        end

        integer_arrays = [
          'default_groups'
        ]
        integer_arrays.each do |ia|
          @attributes[ia] = self[ia].map { |i| i.to_i }
        end
      end

      def filename
        self.class.filename
      end
  end
end
