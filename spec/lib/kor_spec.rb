require 'spec_helper'

describe Kor do
  
  it "should create authentication data" do
    ActionMailer::Base.deliveries.size.should == 0
  
    User.make(:name => 'john', :email => 'john@doe.com', :expires_at => 1.week.from_now)
    User.make(:name => 'lisa', :email => 'lisa@coleman.com', :expires_at => 3.week.from_now)
    User.make(:name => 'admin', :email => 'admin@coneda.net')
    User.count.should eql(3)
  
    Kor.notify_upcoming_expiries
    
    ActionMailer::Base.deliveries.size.should eql(1)
  end
  
end
