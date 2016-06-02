require 'rails_helper'

describe UserMailer do

  it 'should send password reset mails' do
    admin = FactoryGirl.create :admin
    described_class.reset_password(admin).deliver_now
    expect(ActionMailer::Base.deliveries.size).to eq(1)
  end

end