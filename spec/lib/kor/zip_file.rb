require "spec_helper"

describe Kor::ZipFile do

  include DataHelper

  it "should add files with a given internal path" do
    filename = "#{Rails.root}/tmp/sample.zip"
    system "rm -f #{filename}"
    zip = described_class.new(filename)
    zip.add "#{Rails.root}/LICENSE", :as => "info/LICENSE"
    zip.pack
    `unzip -l #{zip.filename}`.should match(/info\/LICENSE/)
    zip.destroy
  end

  it "should be able to attach itself to a download" do
    test_data_for_auth

    filename = "#{Rails.root}/tmp/sample.zip"
    system "rm -f #{filename}"
    zip = described_class.new(filename, :user_id => User.first.id, :file_name => "sample.zip")
    zip.add "#{Rails.root}/LICENSE", :as => "info/LICENSE"
    download = zip.create_as_download

    Download.count.should == 1
  end

end