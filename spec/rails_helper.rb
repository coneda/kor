require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)

# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?

require 'rspec/rails'
require 'factory_girl_rails'

Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  include DataHelper

  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  config.use_transactional_fixtures = true
  # config.infer_spec_type_from_file_location!
  # config.filter_rails_from_backtrace!
  # config.filter_gems_from_backtrace("gem name")

  config.before :all do
    system "cat /dev/null >| #{Rails.root}/log/test.log"

    XmlHelper.compile_validator

    DatabaseCleaner.clean_with :truncation
    DatabaseCleaner.clean
    # DatabaseCleaner.strategy = :transaction

    Rails.application.load_seed
    default_setup
  end

  # config.around(:each) do |example|
  #   DatabaseCleaner.cleaning do
  #     example.run
  #   end
  # end

  config.around :each do |example|
    begin
      example.run
    rescue ActiveRecord::RecordInvalid => e
      binding.pry
      p e.record.errors.full_messages
    end
  end

  config.before :each do |example|
    FactoryGirl.reload

    if example.metadata[:elastic]
      Kor::Elastic.enable
      Kor::Elastic.reset_index
      Kor::Elastic.index_all full: true
    else
      Kor::Elastic.disable
    end

    if example.metadata[:seed]
      Rails.application.load_seed
    end

    if example.metadata[:type] == :controller
      request.headers["accept"] = 'application/json'
    end

    ActionMailer::Base.deliveries = []
    system "rm -rf #{Medium.media_data_dir}/*"
    system "rm -rf #{Rails.root}/tmp/export_spec"
    
    Kor::Settings.purge_files!
    Kor::Settings.instance.ensure_fresh
  end
end
