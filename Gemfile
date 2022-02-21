source 'https://rubygems.org'

gem 'acts_as_list'
gem 'acts-as-taggable-on', '~> 7.0'
gem 'colorize'
gem 'dotenv'
gem 'exifr', '1.1.1'
gem 'hirb'
gem 'httpclient'
gem 'jbuilder'
gem 'mysql2', '~> 0.5.3'
gem 'parslet'
gem 'puma'
gem 'rack-cors', require: 'rack/cors'
gem 'rails', '~> 6.1.0'
gem 'RedCloth'
gem 'responders' # , '~> 2.0'
gem 'ruby-progressbar'
gem 'semantic', git: 'https://github.com/jlindsey/semantic'
gem 'test-unit'

if !ENV['RAILS_GROUPS'] || !ENV['RAILS_GROUPS'].match(/assets/)
  # TODO: all of these load activerecord on asset precompiliation so we load
  # (and configure) it in app/controllers/application_controller.rb
  gem 'awesome_nested_set' #, '~> 3.1.1'
  gem 'factory_bot_rails'
  gem 'paranoia'
end

group :test do
  gem 'capybara'
  gem 'connection_pool'
  gem 'cucumber-rails', require: false
  gem 'database_cleaner-active_record'
  gem 'factory_bot'
  gem 'selenium-webdriver'
  gem 'simplecov', require: false
  gem 'vcr'
  gem 'webdrivers'
  gem 'webmock'
end

group :development do
  gem 'brakeman', require: false
  gem 'debase-ruby_core_source'
  gem 'listen'
  gem 'method_profiler'
  gem 'rubocop', require: false
  gem 'sql_origin'
end

group :test, :development do
  gem 'byebug'
  gem 'rspec-rails', '~> 4.1.2'
  gem 'pry'
end

group :production do
  gem 'exception_notification', '4.4.3'
end

group :import_export do
  gem 'spreadsheet', '~> 1.1.8'
end
