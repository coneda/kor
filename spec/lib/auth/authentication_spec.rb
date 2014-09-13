require "spec_helper"

describe Auth::Authentication do

  it "should create users when they don't exist" do
    expect(User).to receive(:generate_password).exactly(:once)
    user = described_class.authorize("jdoe")

    expect(user.name).to eq("jdoe")
  end

  it "should call external auth scripts" do
    FactoryGirl.create :user, :name => "example_auth"

    expect(described_class.login "jdoe", "wrong").to be_false
    expect(described_class.login "jdoe", "123456").to be_true

    expect(User.count).to eq(2)
    expect(User.last.parent_username).to eq("example_auth")
  end

end