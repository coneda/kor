require 'rails_helper'

RSpec.describe Kor do
  it "should notify expiring users" do
    jdoe = User.find_by! name: 'jdoe'
    mrossi = User.find_by! name: 'mrossi'

    jdoe.update expires_at: 1.week.from_now
    mrossi.update expires_at: 3.weeks.from_now

    Kor::Tasks.notify_expiring_users
    expect(ActionMailer::Base.deliveries.size).to eql(1)
  end

  it "should generate a repository UUID" do
    expect(Kor.settings['repository_uuid']).to be_nil
    
    uuid = Kor.repository_uuid
    expect(uuid).not_to be_nil
    expect(Kor.settings['repository_uuid']).to eq(uuid)
  end
end
