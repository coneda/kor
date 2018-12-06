class ActiveRecord::Base
  mattr_accessor :shared_connection
  @@shared_connection = nil

  def self.connection
    @@shared_connection || ConnectionPool::Wrapper.new(size: 1) { retrieve_connection }
  end
end
ActiveRecord::Base.shared_connection = ActiveRecord::Base.connection

World(DataHelper)

TestHelper.setup_vcr :cucumber
TestHelper.setup

Capybara.server_port = 47001
Capybara.default_max_wait_time = 5
# Capybara.ignore_hidden_elements = true
Capybara.default_driver = :selenium
# Capybara.default_driver = :selenium_chrome

Capybara.register_driver :headless_chrome do |app|
  profile = Selenium::WebDriver::Chrome::Profile.new
  profile["download.default_directory"] = Rails.root.join('tmp')

  Capybara::Selenium::Driver.new app, browser: :chrome, profile: profile, args: [
    'headless',
    'window-size=1280x960'
  ]
end

if ENV['HEADLESS']
  Capybara.default_driver = :headless_chrome
end

Around('@notravis') do |scenario, block|
  if ENV['TRAVIS'] != 'true'
    block.call
  end
end

Around do |scenario, block|
  TestHelper.around_each(&block)
  # DatabaseCleaner.cleaning(&block)
end

Before do |scenario|
  TestHelper.before_each(:cucumber, self, scenario)

  # ensure localstorage doesn't carry over data beyond scenarios
  @local_storage_flushed = false
  orig = Capybara.current_session.method(:visit)
  allow(Capybara.current_session).to receive(:visit) { |*args|
    result = orig.call(*args)
    unless @local_storage_flushed
      page.execute_script('try {Lockr.flush()} catch (e) {}')
      @local_storage_flushed = true
    end
    result
  }
  # unless scenario.tags.any?{|st| st.name == '@noseed'}
  #   eval File.read("#{Rails.root}/db/seeds.rb")
  # end

  # system "rm -f #{Rails.root}/config/kor.app.test.yml"
  # Kor::Config.reload!

  # if scenario.tags.any?{|st| st.name == "@elastic"}
  #   Kor::Elastic.enable
  #   Kor::Elastic.reset_index
  # else
  #   Kor::Elastic.disable
  # end

  # if scenario.tags.any?{|st| st.name == "@nodelay"}
  #   Delayed::Worker.delay_jobs = false
  # else
  #   Delayed::Worker.delay_jobs = true
  # end
end

# After do |scenario|
#   Cucumber::Rails::Database.before_js
# end

# Transform /^table:name,distinct_name,kind,collection/ do |table|
#   table.map_column!(:distinct_name) {|d| d == "" ? nil : d}
#   table.map_headers! {|h| h.to_sym}
#   table
# end

# VCR.configure do |c|
#   c.cassette_library_dir = 'spec/fixtures/cassettes'
#   c.hook_into :webmock
#   c.default_cassette_options = {:record => :new_episodes}
#   c.allow_http_connections_when_no_cassette = true
#   c.ignore_request do |request|
#     uri = URI.parse(request.uri)
#     uri.port == 7055
#   end
# end

# VCR.cucumber_tags do |t|
#   t.tag "@vcr", :use_scenario_name => true
# end
