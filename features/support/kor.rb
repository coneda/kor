require 'webdrivers'

Webdrivers.cache_time = 86400 # 24 hours
# Webdrivers.logger.level = :DEBUG

class ActiveRecord::Base
  mattr_accessor :shared_connection
  @@shared_connection = nil

  def self.connection
    @@shared_connection || ConnectionPool::Wrapper.new(size: 1, timeout: 25){ retrieve_connection }
  end
end
ActiveRecord::Base.shared_connection = ActiveRecord::Base.connection

# require 'active_record/connection_adapters/abstract_mysql_adapter'
# class ActiveRecord::ConnectionAdapters::AbstractMysqlAdapter
#   SEMAPHORE = Mutex.new
#   def execute(sql, name = nil)
#     begin
#       raise 'Debugging'
#     rescue => e
#       SEMAPHORE.synchronize{ log(sql, name){ @connection.query(sql) } }
#     end
#   end
# end

World(DataHelper)

SuiteHelper.setup_vcr :cucumber
SuiteHelper.setup :cucumber

Capybara.server_port = 47001
Capybara.default_max_wait_time = 5

download_path = Rails.root.join('tmp', 'test_downloads').to_s
system "mkdir -p '#{download_path}'"

Capybara.register_driver :selenium_chrome_headless do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  [
    'headless',
    'window-size=1280x960',
    'remote-debugging-address=0.0.0.0',
    'remote-debugging-port=9222'
  ].each{|a| options.add_argument(a)}

  # set download path
  options.add_preference 'download.default_directory', download_path

  Capybara::Selenium::Driver.new(app, browser: :chrome, capabilities: [options])
end

Capybara.register_driver :firefox_custom do |app|
  profile = Selenium::WebDriver::Firefox::Profile.new
  profile['browser.download.dir'] = download_path
  profile['browser.download.lastDir'] = download_path
  profile['browser.download.folderList'] = 2
  profile['browser.helperApps.neverAsk.saveToDisk'] = "application/pdf,application/zip"
  profile['browser.download.manager.showWhenStarting'] = false
  profile['pdfjs.disabled'] = true
  options = Selenium::WebDriver::Firefox::Options.new(profile: profile)

  Capybara::Selenium::Driver.new(app, browser: :firefox, capabilities: [options])
end

Capybara.default_driver = :firefox_custom
# Capybara.default_driver = :selenium

if ENV['HEADLESS']
  Capybara.default_driver = :selenium_chrome_headless
  # Capybara.default_driver = :selenium_headless
end

Around('@notravis') do |_scenario, block|
  if ENV['TRAVIS'] != 'true'
    block.call
  end
end

Around do |_scenario, block|
  SuiteHelper.around_each(&block)
end

Before do |scenario|
  reset_browser!
  SuiteHelper.before_each(:cucumber, self, scenario)
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
