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

  it "should display ALL primary and secondary related entities within the gallery"
  it "should limit the amount of records returned by the path api"
  it "automatically created generators should not render anything when value is empty"
  
end
