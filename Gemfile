source 'https://rubygems.org'

gem 'acts-as-taggable-on', '~> 4.0.0'
gem 'colorize'
gem 'delayed_paperclip'
gem 'dotenv'
gem 'exifr', '1.1.1'
gem 'hirb'
gem 'httpclient'
gem 'jbuilder'
gem 'mysql2', '~> 0.4.5'
gem 'paperclip'
gem 'parslet'
gem 'rack-cors', require: 'rack/cors'
gem 'rails', '~> 5.0.7'
gem 'RedCloth'
gem 'responders', '~> 2.0'
gem 'ruby-progressbar'
gem 'semantic', git: 'https://github.com/jlindsey/semantic'
gem 'test-unit'

if !ENV['RAILS_GROUPS'] || !ENV['RAILS_GROUPS'].match(/assets/)
  # TODO: all of these load activerecord on asset precompiliation so we load
  # (and configure) it in app/controllers/application_controller.rb
  gem 'awesome_nested_set', '~> 3.1.1'
  gem 'factory_girl_rails'
  gem 'paranoia', '~> 2.2'
end

group :test do
  gem 'capybara'
  gem 'connection_pool'
  gem 'cucumber-rails', require: false
  gem 'database_cleaner'
  gem 'rspec-rails', '~> 3.8.2'
  gem 'selenium-webdriver'
  gem 'simplecov', require: false
  gem 'vcr'
  gem 'webmock'
end

group :development do
  gem 'brakeman', require: false
  gem 'debase-ruby_core_source'
  gem 'method_profiler'
  gem 'rubocop', require: false
  gem 'sql_origin'
end

group :test, :development do
  gem 'byebug'
  gem 'pry'
  gem 'thin'
end

group :production do
  gem 'exception_notification'
  gem 'puma'
end

group :import_export do
  gem 'spreadsheet', '~> 1.1.8'
end
