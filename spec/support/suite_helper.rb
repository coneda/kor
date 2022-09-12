module SuiteHelper
  def self.require_modules
    # we do this so they get loaded after SimpleCov
    require 'support/data_helper'
    require 'support/xml_helper'
  end

  def self.setup(framework)
    DatabaseCleaner.clean_with :truncation

    if framework == :rspec
      DatabaseCleaner.strategy = :transaction
    end

    if framework == :cucumber
      DatabaseCleaner.strategy = :truncation
    end

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

    # if framework == :cucumber
    #   system 'mysqldump',
    #     '-h', '127.0.0.1',
    #     '-u', 'root',
    #     '-p', 'root',
    # end

    system "rm -rf #{Rails.root}/tmp/test.media.clone"
    system "mv #{ENV['DATA_DIR']}/media #{Rails.root}/tmp/test.media.clone"
  end

  def self.around_each(framework)
    if framework == :rspec
      DatabaseCleaner.start
      yield
      DatabaseCleaner.clean
    end

    if framework == :cucumber
      DatabaseCleaner.clean
      Rails.application.load_seed
      DataHelper.default_setup

      yield
    end
  end

  def self.before_each(framework, scope, test)
    system "rm -rf #{ENV['DATA_DIR']}/media/"
    system "cp -a #{Rails.root}/tmp/test.media.clone #{ENV['DATA_DIR']}/media"

    FactoryBot.reload
    Kor::Auth.sources(refresh: true)

    use_elastic = (
      ((framework == :rspec) && test.metadata[:elastic]) ||
      ((framework == :cucumber) && test.tags.any?{ |st| st.name == '@elastic' })
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

  def self.after_each(framework, scope, test)
    if framework == :rspec
      extend ActiveSupport::Testing::TimeHelpers
      travel_back
    end

    if framework == :cucumber
      scope.travel_back
    end
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
        if ENV['ELASTIC_URL'].present?
          elastic_uri = URI.parse(ENV['ELASTIC_URL'])
          uri = URI.parse(r.uri)

          uri.port == 7055 || (
            elastic_uri.host == uri.host &&
            elastic_uri.port == uri.port
          )
        end
      end
    end
  end

  def self.setup_simplecov(framework)
    if ENV['COVERAGE'] == 'true'
      require 'simplecov'

      SimpleCov.start :rails do
        command_name framework.to_s
        use_merging true
        merge_timeout 3600
        coverage_dir 'tmp/coverage'

        track_files '{bin,config,app,lib}/**/*.{rb,rake}'
      end

      puts "performing coverage analysis (suite '#{framework}')"
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
