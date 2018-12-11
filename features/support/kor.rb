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

Around('@notravis') do |_scenario, block|
  if ENV['TRAVIS'] != 'true'
    block.call
  end
end

Around do |_scenario, block|
  TestHelper.around_each(&block)
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
end
