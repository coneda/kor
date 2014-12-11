require "spec_helper"

describe Auth::Authentication do

  before :each do
    FactoryGirl.create :ldap_template
  end

  it "should create users when they don't exist" do
    expect(User).to receive(:generate_password).exactly(:once)
    user = described_class.authorize "jdoe", "email" => "jdoe@coneda.net"

    expect(user.name).to eq("jdoe")
  end

  it "should call external auth scripts" do
    FactoryGirl.create :user, :name => "example_auth", :email => 'ea@example.com'

    expect(described_class.login "jdoe", "wrong").to be_false
    expect(described_class.login "jdoe", "123456").to be_true

    expect(User.count).to eq(3)
    expect(User.last.parent_username).to eq("ldap")
  end

  it "should escape double quotes in username and password" do
    expect(described_class.login "\" echo 'bla' #", "123456").to be_false
  end

  it "should pass passwords with special characters to external auth scripts" do
    user = described_class.login "cangoin", "$0.\/@#"
    expect(user.name).to eq("cangoin")
  end

  it "should pass usernames with special characters to external auth scripts" do
    user = described_class.login "can.go.in", "$0.\/@#"
    expect(user.name).to eq("can.go.in")
  end

end