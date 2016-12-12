require 'simplecov'

require "cucumber/rspec/doubles"
require 'capybara/poltergeist'
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

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app,
    # debug: true,
    js_errors: true,
    inspector: false
  )
end

Capybara.register_driver :chromium do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end

Capybara.register_driver :marionette do |app|
  Selenium::WebDriver.for :firefox, marionette: true
end

Capybara.default_max_wait_time = 5
Capybara.wait_on_first_by_default = true
Capybara.javascript_driver = :chromium
# once marionette works
# Capybara.javascript_driver = :marionette

if ENV['HEADLESS']
  Capybara.javascript_driver = :poltergeist
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
