require 'webdrivers'

Webdrivers.cache_time = 86_400 # 24 hours
# Webdrivers.logger.level = :DEBUG

World(DataHelper)

SuiteHelper.setup_vcr :cucumber
SuiteHelper.setup :cucumber

Capybara.server_port = 47_001
Capybara.default_max_wait_time = 5

Capybara.register_driver :selenium_chrome_headless do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  [
    'headless',
    'window-size=1280x960',
    'remote-debugging-address=0.0.0.0',
    'remote-debugging-port=9222'
  ].each{ |a| options.add_argument(a) }

  # set download path
  path = Rails.root.join('tmp', 'test_downloads').to_s
  system "mkdir -p '#{path}'"
  options.add_preference 'download.default_directory', path

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

Capybara.default_driver = :selenium

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
  SuiteHelper.around_each(:cucumber, &block)
end

Before do |scenario|
  reset_browser!
  SuiteHelper.before_each(:cucumber, self, scenario)
end

After do |scenario|
  SuiteHelper.after_each(:rspec, self, scenario)
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
