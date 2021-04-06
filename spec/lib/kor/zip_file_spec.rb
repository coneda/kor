require 'rails_helper'

RSpec.describe Kor::ZipFile do
  it "should add files with a given internal path" do
    filename = "#{Rails.root}/tmp/sample.zip"
    system "rm -f #{filename}"
    zip = described_class.new(filename)
    zip.add "#{Rails.root}/LICENSE", :as => "info/LICENSE"
    zip.pack
    expect(`unzip -l #{zip.filename}`).to match(/info\/LICENSE/)
    zip.destroy
  end

  it "should be able to attach itself to a download" do
    filename = "#{Rails.root}/tmp/sample.zip"
    system "rm -f #{filename}"
    zip = described_class.new(filename, :user_id => User.first.id, :file_name => "sample.zip")
    zip.add "#{Rails.root}/LICENSE", :as => "info/LICENSE"
    zip.build

    expect(Download.count).to eq(1)
  end
end
