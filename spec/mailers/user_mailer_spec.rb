require 'rails_helper'

RSpec.describe UserMailer do
  before :each do
    ActionMailer::Base.default_url_options[:host] = 'example.com'
  end

  it 'should send password reset mails' do
    described_class.reset_password(admin).deliver_now
    expect(ActionMailer::Base.deliveries.size).to eq(1)
  end

  it 'should not cache the from address when settings are updated' do
    Kor.settings.update 'maintainer_mail' => 'admin@wendig.io'
    Kor.settings.ensure_fresh

    described_class.reset_password(jdoe).deliver_now
    expect(ActionMailer::Base.deliveries[0].from[0]).to eq('admin@wendig.io')
  end

  it "should send mails with the user's locale if available" do
    expires_at = 2.days.from_now
    admin.update_attributes expires_at: expires_at

    expect(admin.locale).to be_nil
    expect(Kor.settings['default_locale']).to eq('en')
    expect(I18n.default_locale).to eq(:en)

    described_class.upcoming_expiry(admin).deliver_now
    mail = ActionMailer::Base.deliveries.last
    expect(mail.body).to include(expires_at.strftime('%Y-%m-%d'))
    expect(mail.body).to include('http://example.com')
    expect(mail.body).to include('Please contact the administrator')

    admin.update_attributes locale: 'de'
    described_class.upcoming_expiry(admin).deliver_now
    mail = ActionMailer::Base.deliveries.last
    expect(mail.body).to include(expires_at.strftime('%Y-%m-%d'))
    expect(mail.body).to include('http://example.com')
    expect(mail.body).to include('mit dem Administrator in Verbindung')
  end
end
