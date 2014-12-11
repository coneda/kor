require 'spec_helper'

describe Kor do
  
  it "should create authentication data" do
    ActionMailer::Base.deliveries.size.should == 0
  
    FactoryGirl.create :jdoe, :expires_at => 1.week.from_now
    FactoryGirl.create :hmustermann, :expires_at => 3.weeks.from_now
    FactoryGirl.create :admin
    User.count.should eql(3)
  
    Kor.notify_upcoming_expiries
    
    ActionMailer::Base.deliveries.size.should eql(1)
  end
  
end
