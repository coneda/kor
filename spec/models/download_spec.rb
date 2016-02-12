require 'rails_helper'

describe Download do
  include DataHelper

  before :each do
    system "rm -f #{Rails.root}/data/downloads/*"
    test_data_for_auth
    ActionMailer::Base.deliveries = []
  end

  it "should move the file to the download folder" do
    download = Download.create(:file_name => "test.zip", :user => User.first, :data => File.open("README.md"))
    expect(File.exists?(download.path)).to be_truthy
  end
  
  it "should send mail when finished" do
    download = Download.create(:file_name => "test.zip", :user => User.first, :data => "Hello", :notify_user => true)
    expect(File.read(Download.last.path)).to eq("Hello")
    expect(ActionMailer::Base.deliveries.size).to eql(1)
  end

end
