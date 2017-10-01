require 'simplecov'

require "cucumber/rspec/doubles"
require 'factory_girl_rails'

DatabaseCleaner.clean_with :truncation
DatabaseCleaner.strategy = :truncation
# Cucumber::Rails::Database.javascript_strategy = :truncation

Around do |scenario, block|
  DatabaseCleaner.cleaning(&block)
end

Before do |scenario|
  eval File.read("#{Rails.root}/db/seeds.rb")

  system "rm -f #{Rails.root}/config/kor.app.test.yml"
  Kor::Config.reload!

  if scenario.tags.any?{|st| st.name == "@elastic"}
    Kor::Elastic.enable
    Kor::Elastic.reset_index
  else
    Kor::Elastic.disable
  end

  if scenario.tags.any?{|st| st.name == "@nodelay"}
    Delayed::Worker.delay_jobs = false
  else
    Delayed::Worker.delay_jobs = true
  end
end

Capybara.default_max_wait_time = 5

Capybara.javascript_driver = :selenium
Capybara.javascript_driver = :selenium_chrome

if ENV['HEADLESS']
  Capybara.register_driver :headless_chrome do |app|
    capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
      chromeOptions: {args: ['headless', 'disable-gpu']}
    )
    Capybara::Selenium::Driver.new app,
      browser: :chrome,
      desired_capabilities: capabilities
  end
  Capybara.javascript_driver = :headless_chrome
end

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/cassettes'
  c.hook_into :webmock
  c.default_cassette_options = {:record => :new_episodes}
  c.allow_http_connections_when_no_cassette = true
  c.ignore_request do |request|
    uri = URI.parse(request.uri)
    uri.port == 7055
  end
end

VCR.cucumber_tags do |t|
  t.tag "@vcr", :use_scenario_name => true
end
