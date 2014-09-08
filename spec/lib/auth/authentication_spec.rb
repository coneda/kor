require "spec_helper"

describe Auth::Authentication do

  it "should create users when they don't exist" do
    expect(User).to receive(:generate_password).exactly(:once)

    user = described_class.authorize("jdoe")

    expect(user.name).to eq("jdoe")
  end

end