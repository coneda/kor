source 'https://rubygems.org'

gem 'rails', '3.2.17'

gem 'delayed_paperclip', "= 2.4.5", :require => 'delayed_paperclip/railtie'
gem "paperclip", "= 2.4.5"
gem 'delayed_job_active_record'
gem 'delayed_job'
gem 'daemons'

gem 'mysql2'
gem "RedCloth"
gem "uuidtools"
gem "will_paginate", "= 3.0.3"
gem "parslet"
gem "xml-simple", '1.0.14', :require => "xmlsimple"
gem "exifr", '1.1.1'
gem "mongo"
gem "bson_ext", '1.3.1', :require => false
gem "haml"
gem "sass"
gem 'httparty'
gem 'mime-types', '1.16', :require => 'mime/types'
gem 'acts-as-taggable-on', '~> 2.2.2'
gem 'system_timer', :platforms => [:ruby_18]

gem 'kor_api', :path => './plugins/kor_api'
gem 'kor_index', :path => './plugins/kor_index'

gem "sprockets"
gem "jquery-rails", "~> 2.2.1"

gem 'awesome_nested_set', :git => 'https://github.com/galetahub/awesome_nested_set.git'

gem "sunspot_rails"
gem "sunspot_solr"

gem 'json'
gem 'builder'
gem 'net-ldap'

group :assets do
  gem "therubyracer"
  gem 'coffee-rails'
  gem "sass-rails"
  gem 'uglifier', '>= 1.0.3'
end

group :test do
  gem 'cucumber-rails', :require => false
  gem 'poltergeist'
  gem 'selenium-webdriver'
  gem 'rspec-rails'
  gem 'capybara'
  gem 'database_cleaner'
  gem 'webrat', '0.7.3'
  gem 'faker'
  gem 'sham'
  gem 'factory_girl_rails'
  gem 'machinist', '1.0.6', :require => 'machinist/active_record'
end

group :test, :development do
  gem 'thin'
  gem 'ruby-debug', :platforms => [:ruby_18]
  gem 'debugger', :platforms => [:ruby_19, :ruby_20]
  gem 'rcov', :platforms => [:ruby_18]
end
