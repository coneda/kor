require 'rails_helper'

RSpec.describe "Configuration System" do
  it "should pick up mailer configuration from .env files" do
    dm = Rails.configuration.action_mailer
    expect(dm.delivery_method).to eq(:test)
  end
end
