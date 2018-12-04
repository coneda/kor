source 'https://rubygems.org'

gem 'acts-as-taggable-on', '~> 3.5'
gem 'colorize'
gem 'daemons'
gem 'delayed_paperclip'
gem 'dotenv-rails'
gem 'exifr', '1.1.1'
gem 'hirb'
gem 'httpclient'
gem 'jbuilder'
gem 'mysql2'
gem 'paperclip'
gem 'parslet'
gem 'rack-cors', require: 'rack/cors'
gem 'rails', '~> 4.2.11'
gem 'RedCloth'
gem 'responders', '~> 2.0'
gem 'ruby-progressbar'
gem 'semantic', git: 'https://github.com/jlindsey/semantic'
gem 'sprockets-rails'
gem 'sucker_punch', '~> 2.0'
gem 'test-unit'

if !ENV['RAILS_GROUPS'] || !ENV['RAILS_GROUPS'].match(/assets/)
  # TODO: all of these load activerecord on asset precompiliation so we load
  # (and configure) it in app/controllers/application_controller.rb
  gem 'awesome_nested_set', '~> 3.1.1'
  gem 'delayed_job_active_record'
  gem 'factory_girl_rails'
  gem 'paranoia', '~> 2.2'
end

group :test do
  gem 'capybara'
  gem 'connection_pool'
  gem 'cucumber-rails', require: false
  gem 'database_cleaner'
  gem 'rspec-rails', '~> 3.7.2'
  gem 'selenium-webdriver'
  gem 'simplecov', require: false
  gem 'test_after_commit'
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
  gem 'quiet_assets'
  gem 'thin'
end

group :production do
  gem 'exception_notification'
  gem 'puma'
end

group :production, :test do
  gem 'therubyracer'
  gem 'uglifier'
end

group :import_export do
  gem 'spreadsheet'
end
