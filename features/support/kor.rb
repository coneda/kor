class ActiveRecord::Base
  mattr_accessor :shared_connection
  @@shared_connection = nil

  def self.connection
    @@shared_connection || ConnectionPool::Wrapper.new(size: 1, timeout: 15) { retrieve_connection }
  end
end
ActiveRecord::Base.shared_connection = ActiveRecord::Base.connection

require 'active_record/connection_adapters/abstract_mysql_adapter'
class ActiveRecord::ConnectionAdapters::AbstractMysqlAdapter
  SEMAPHORE = Mutex.new
  def execute(sql, name = nil)
    begin
      raise 'Debugging'
    rescue => e
      SEMAPHORE.synchronize { log(sql, name) { @connection.query(sql) } }
    end
  end
end

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

  opts = Selenium::WebDriver::Chrome::Options.new
  opts.add_argument 'headless'
  opts.add_argument 'window-size=1280x960'

  Capybara::Selenium::Driver.new app, {
    browser: :chrome,
    profile: profile,
    options: opts
  }
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
