source 'https://rubygems.org'

gem 'acts_as_list'
gem 'acts-as-taggable-on', '~> 9.0.0'
gem 'awesome_nested_set', '~> 3.5.0'
gem 'colorize'
gem 'dotenv'
gem 'exifr', '1.1.1'
gem 'factory_bot_rails'
gem 'hirb'
gem 'httpclient'
gem 'jbuilder'
gem 'kramdown'
gem 'kt-delayed_paperclip'
gem 'kt-paperclip'
gem 'mysql2'
gem 'paranoia', '~> 2.2'
gem 'parslet'
gem 'puma'
gem 'rack-cors', require: 'rack/cors'
gem 'rails', '~> 7.0.10'
gem 'RedCloth'
gem 'responders'
gem 'ruby-progressbar'
gem 'semantic', git: 'https://github.com/jlindsey/semantic'

group :test do
  gem 'capybara'
  gem 'connection_pool'
  gem 'cucumber-rails', require: false
  gem 'database_cleaner'
  gem 'rspec-rails', '~> 5.1.0'
  gem 'selenium-webdriver'
  gem 'simplecov', require: false
  gem 'vcr'
  # gem 'webdrivers'
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
  gem 'yard'
end

group :production do
  gem 'exception_notification'
end

group :import_export do
  gem 'spreadsheet', '~> 1.1.8'
end
