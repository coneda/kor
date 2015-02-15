system "cat /dev/null >| log/test.log"

require 'cucumber/rails'
require 'capybara/poltergeist'

require 'rspec/mocks'
World(RSpec::Mocks::ExampleMethods)

Before do
  RSpec::Mocks.setup  
end

After do
  begin
    RSpec::Mocks.verify
  ensure
    RSpec::Mocks.teardown
  end
end

Capybara.default_selector = :css

Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.new(app, 
    :browser => :chrome
  )
end

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app,
    # :debug => true,
    :js_errors => true,
    :inspector => true
  )
end

if ENV['HEADLESS']
  Capybara.javascript_driver = :poltergeist
end

ActionController::Base.allow_rescue = false

Before do |scenario|
  file = "#{Rails.root}/tmp/harmful.txt"
  system "rm -f #{file}"
  system "rm -f #{Rails.root}/config/kor.app.test.yml"
  Kor.config true

  if scenario.source_tags.any?{|st| st.name == "@elastic"}
    Kor::Elastic.reset_index
  else
    allow(Kor::Elastic).to receive(:enabled?).and_return(false)
    allow(Kor::Elastic).to receive(:request).and_return([200, {}, {}])
  end
end

<<<<<<< HEAD
ActiveSupport::Deprecation.behavior = Proc.new do |message, stack|
  message << ":\n"
  stack.each do |l|
    message << "#{l}\n" if l.match(Rails.root)
  end
  
  deprecation_logger.info "#{message}#{'-' * 80}"
end

=======
# Capybara defaults to CSS3 selectors rather than XPath.
# If you'd prefer to use XPath, just uncomment this line and adjust any
# selectors in your step definitions to use the XPath syntax.
# Capybara.default_selector = :xpath

# By default, any exception happening in your Rails application will bubble up
# to Cucumber so that your scenario will fail. This is a different from how 
# your application behaves in the production environment, where an error page will 
# be rendered instead.
#
# Sometimes we want to override this default behaviour and allow Rails to rescue
# exceptions and display an error page (just like when the app is running in production).
# Typical scenarios where you want to do this is when you test your error pages.
# There are two ways to allow Rails to rescue exceptions:
#
# 1) Tag your scenario (or feature) with @allow-rescue
#
# 2) Set the value below to true. Beware that doing this globally is not
# recommended as it will mask a lot of errors for you!
#
>>>>>>> exposed a relationships api
ActionController::Base.allow_rescue = false

begin
  DatabaseCleaner.strategy = :truncation
rescue NameError
  raise "You need to add database_cleaner to your Gemfile (in the :test group) if you wish to use it."
end

Cucumber::Rails::Database.javascript_strategy = :truncation
