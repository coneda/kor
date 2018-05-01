ENV["RAILS_ENV"] ||= 'test'
require 'spec_helper'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

require 'factory_girl_rails'

Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

RSpec.configure do |config|
  config.use_transactional_fixtures = false
  config.infer_base_class_for_anonymous_controllers = false
  # config.infer_spec_type_from_file_location!

  config.before :all do
    system "cat /dev/null >| #{Rails.root}/log/test.log"

    XmlHelper.compile_validator

    DatabaseCleaner.clean_with :truncation
    DatabaseCleaner.strategy = :transaction
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

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
    else
      Kor::Elastic.disable
    end

    if example.metadata[:seed]
      Rails.application.load_seed
    end

    ActionMailer::Base.deliveries = []
    system "rm -rf #{Medium.media_data_dir}/*"
    system "rm -f #{Kor::Config.app_config_file}"
    system "rm -rf #{Rails.root}/tmp/export_spec"
    Kor::Config.reload!
  end
end
