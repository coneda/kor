require 'rails_helper'

RSpec.describe UserMailer do
  before :each do
    ActionMailer::Base.default_url_options[:host] = 'example.com'
  end

  it 'should send password reset mails' do
    described_class.reset_password(admin).deliver_now
    expect(ActionMailer::Base.deliveries.size).to eq(1)
  end
end