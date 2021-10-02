module SuiteHelper
  def self.require_modules
    # we do this so they get loaded after SimpleCov
    require 'support/data_helper'
    require 'support/xml_helper'
  end

  def self.setup
    DatabaseCleaner.clean_with :truncation
    DatabaseCleaner.strategy = :transaction

    system "cat /dev/null >| #{Rails.root}/log/test.log"

    XmlHelper.compile_validator

    Kor::Settings.purge_files!
    Kor::Settings.instance.ensure_fresh
    Kor.settings.update(
      'primary_relations' => ['shows'],
      'secondary_relations' => ['has been created by']
    )

    Rails.application.load_seed
    DataHelper.default_setup

    system "rm -rf #{Rails.root}/tmp/test.media.clone"
    system "mv #{ENV['DATA_DIR']}/media #{Rails.root}/tmp/test.media.clone"
  end

  def self.around_each(&block)
    DatabaseCleaner.start
    yield
    DatabaseCleaner.clean
  end

  def self.before_each(framework, scope, test)
    system "rm -rf #{ENV['DATA_DIR']}/media/"
    system "cp -a #{Rails.root}/tmp/test.media.clone #{ENV['DATA_DIR']}/media"

    FactoryGirl.reload
    Kor::Auth.sources(refresh: true)

    use_elastic = (
      framework == :rspec && test.metadata[:elastic] ||
      framework == :cucumber && test.tags.any?{ |st| st.name == '@elastic' }
    )

    if use_elastic
      Kor::Elastic.enable!
      Kor::Elastic.reset_index
      Kor::Elastic.index_all full: true
    else
      Kor::Elastic.disable!
    end

    if framework == :rspec && test.metadata[:type].to_s == 'controller'
      scope.request.headers["accept"] = 'application/json'
      scope.request.content_type = 'application/json'
    end

    ActionMailer::Base.deliveries.clear
    system "rm -rf #{Rails.root}/tmp/export_spec"

    Kor::Settings.purge_files!
    Kor::Settings.instance.ensure_fresh
    Kor.settings.update(
      'primary_relations' => ['shows'],
      'secondary_relations' => ['has been created by']
    )
  end

  def self.setup_vcr(framework)
    require 'vcr'

    VCR.configure do |c|
      c.cassette_library_dir = 'spec/fixtures/cassettes'
      c.hook_into :webmock

      if framework == :rspec
        c.configure_rspec_metadata!
      end

      c.default_cassette_options = {
        record: :new_episodes
        # record: :all
      }
      c.allow_http_connections_when_no_cassette = true

      c.ignore_request do |r|
        elastic_uri = URI.parse(ENV['ELASTIC_URL'])
        uri = URI.parse(r.uri)

        uri.port == 7055 || (
          elastic_uri.host == uri.host &&
          elastic_uri.port == uri.port
        )
      end
    end
  end

  def self.setup_simplecov
    if ENV['COVERAGE'] == 'true'
      require 'simplecov'

      SimpleCov.start 'rails' do
        use_merging true
        merge_timeout 3600
        coverage_dir 'tmp/coverage'

        track_files '{bin,config,app,lib}/**/*.{rb,rake}'
      end

      puts "performing coverage analysis"
    end
  end

  def self.reset_browser
    visit '/empty'
    expect(page).to have_text('logged in as')
    execute_script('localStorage.clear()')
    execute_script('sessionStorage.clear()')
    Capybara.reset_sessions!
  end
end
