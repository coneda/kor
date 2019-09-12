class ActiveRecord::Base
  mattr_accessor :shared_connection
  @@shared_connection = nil

  def self.connection
    @@shared_connection || ConnectionPool::Wrapper.new(size: 1, timeout: 15){ retrieve_connection }
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
      SEMAPHORE.synchronize{ log(sql, name){ @connection.query(sql) } }
    end
  end
end

World(DataHelper)

TestHelper.setup_vcr :cucumber
TestHelper.setup

Capybara.server_port = 47001
Capybara.default_max_wait_time = 5

Capybara.register_driver :selenium_chrome_headless do |app|
  profile = Selenium::WebDriver::Chrome::Profile.new
  profile["download.default_directory"] = Rails.root.join('tmp')

  browser_options = ::Selenium::WebDriver::Chrome::Options.new.tap do |opts|
    opts.args << '--headless'
    opts.args << '--window-size=1280x960'
    opts.args << '--remote-debugging-port=9222'
  end

  Capybara::Selenium::Driver.new app, {
    browser: :chrome,
    profile: profile,
    options: browser_options
  }
end

Capybara.default_driver = :selenium
if ENV['HEADLESS']
  Capybara.default_driver = :selenium_chrome_headless
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
  reset_browser!
  TestHelper.before_each(:cucumber, self, scenario)
end

if ENV['DEBUG_FAILED'] == 'true'
  After do |scenario|
    if scenario.failed?
      if ENV['HEADLESS'] == 'true'
        errors = page.driver.browser.manage.logs.get(:browser)
        if errors.present?
          message = errors.map(&:message).join("\n")
          Kernel.puts message
        end
      end

      # save_screenshot('failed.png', full: true)
      binding.pry
      # now go to http://127.0.0.1:9222 and debug
    end
  end
end
