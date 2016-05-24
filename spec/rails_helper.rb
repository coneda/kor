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
    system "rm -f #{Rails.root}/config/kor.app.test.yml"
    Kor.config true

    system "cat /dev/null >| #{Rails.root}/log/test.log"

    XmlHelper.compile_validator

    DatabaseCleaner.strategy = :deletion
    DatabaseCleaner.clean_with :deletion
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  config.before :each do |example|
    FactoryGirl.reload
    if example.metadata[:elastic]
      Kor::Elastic.reset_index
    end

    ActionMailer::Base.deliveries = []
    system "rm -rf #{Medium.media_data_dir}/*"
    system "rm -f #{Kor::Config.app_config_file}"
    system "rm -rf #{Rails.root}/tmp/export_spec"
    Kor.config(true)
  end
end
