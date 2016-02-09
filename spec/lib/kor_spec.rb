require 'rails_helper'

describe Kor do
  
  it "should create authentication data" do
    expect(ActionMailer::Base.deliveries.size).to eq(0)
  
    FactoryGirl.create :jdoe, :expires_at => 1.week.from_now
    FactoryGirl.create :hmustermann, :expires_at => 3.weeks.from_now
    FactoryGirl.create :admin
    expect(User.count).to eql(3)
  
    Kor.notify_expiring_users
    
    expect(ActionMailer::Base.deliveries.size).to eql(1)
  end

  it "should generate a repository UUID" do
    expect(Kor.config["maintainer.repository_uuid"]).to be_nil
    
    uuid = Kor.repository_uuid
    expect(uuid).not_to be_nil
    expect(Kor.config(true)["maintainer.repository_uuid"]).to eq(uuid)
  end
  
end
