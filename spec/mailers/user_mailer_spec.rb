require 'rails_helper'

describe UserMailer do

  it 'should send password reset mails' do
    admin = FactoryGirl.create :admin
    described_class.reset_password(admin).deliver_now
    expect(ActionMailer::Base.deliveries.size).to eq(1)
  end

  it "should send mails with the user's locale if available" do
    expires_at = 2.days.from_now
    admin = FactoryGirl.create :admin, expires_at: expires_at

    expect(admin.locale).to be_nil
    expect(Kor.config['locale']).to be_nil
    expect(I18n.default_locale).to eq(:en)

    described_class.upcoming_expiry(admin).deliver_now
    mail = ActionMailer::Base.deliveries.last
    expect(mail.body).to include(expires_at.strftime('%Y-%m-%d'))
    expect(mail.body).to include('http://example.com')
    expect(mail.body).to include('Please contact the administrator')

    admin.locale = 'de'
    described_class.upcoming_expiry(admin).deliver_now
    mail = ActionMailer::Base.deliveries.last
    expect(mail.body).to include(expires_at.strftime('%Y-%m-%d'))
    expect(mail.body).to include('http://example.com')
    expect(mail.body).to include('mit dem Administrator in Verbindung')
  end

end