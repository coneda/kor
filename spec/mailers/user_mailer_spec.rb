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
end
