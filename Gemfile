source 'https://rubygems.org'

gem 'rails', '~> 4.2.5'
gem 'responders', '~> 2.0'

gem 'delayed_paperclip'
gem "paperclip"
gem "cocaine"
gem 'daemons'
gem 'mysql2'
gem "RedCloth"
gem "will_paginate", "~> 3.0.3"
gem "parslet"
gem "exifr", '1.1.1'
gem "haml"
gem "sass"
gem 'httpclient'
gem 'acts-as-taggable-on', '~> 3.5'


gem "sprockets-rails"
gem "jquery-rails"
gem 'jquery-ui-rails'
gem 'angularjs-rails', '~> 1.4.8'
gem 'plupload-rails'
gem 'coffee-rails'
gem "sass-rails"

gem 'jbuilder'
gem 'test-unit'

if !ENV['RAILS_GROUPS'] || !ENV['RAILS_GROUPS'].match(/assets/)
  # TODO: all of these load activerecord on asset precompiliation so we load 
  # (and configure) it in app/controllers/application_controller.rb
  gem 'activerecord-session_store'
  gem 'delayed_job_active_record'
  gem 'awesome_nested_set', "~> 3.0.0"
  gem 'factory_girl_rails'
end

gem 'kor_index', path: './plugins/kor_index'

group :test do
  gem 'cucumber-rails', require: false
  gem 'poltergeist'
  gem 'selenium-webdriver'
  gem 'rspec-rails', '~> 3.1'
  gem 'capybara'
  gem 'database_cleaner'
  gem 'vcr'
  gem 'webmock'
  gem 'simplecov', require: false
end

group :development do
  gem 'method_profiler'
  gem 'debase-ruby_core_source'
  gem 'perftools.rb'
end

group :test, :development do
  gem 'thin'
  gem 'quiet_assets'
  gem 'pry'
end

group :production do
  gem 'puma'
  gem "therubyracer"
  gem 'uglifier'
end

group :import_export do
  gem 'spreadsheet'
end