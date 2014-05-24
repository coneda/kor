require 'spec_helper'

describe Download do
  include DataHelper

  before :each do
    system "rm -f #{Rails.root}/data/downloads/*"
    test_data_for_auth
    ActionMailer::Base.deliveries = []
  end

  it "should move the file to the download folder" do
    download = Download.create(:file_name => "test.zip", :user => User.first, :data => File.open("README.md"))
    File.exists?(download.path).should be_true
  end
  
  it "should send mail when finished" do
    download = Download.create(:file_name => "test.zip", :user => User.first, :data => "Hello", :notify_user => true)
    File.read(Download.last.path).should == "Hello"
    ActionMailer::Base.deliveries.size.should eql(1)
  end

end
