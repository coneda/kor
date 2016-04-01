require 'rails_helper'

describe User do

  it "should not allow special characters within the name" do
    user = User.new :name => "test 01"
    user.valid?
    expect(user.errors[:name]).not_to be_empty

    user = User.new :name => "test,01"
    user.valid?
    expect(user.errors[:name]).not_to be_empty

    user.name = "test_01"
    user.valid?
    expect(user.errors[:name]).to be_empty
  end

  it "should allow SAML principals as username" do
    user = User.new name: 'user123@university-abc.de'
    user.valid?
    expect(user.errors[:name]).to be_empty
  end

  it "should allow SAML persistent ids as username" do
    user = User.new name: [
      'https://idp.university-abc.de/idp/shibboleth',
      'https://kor.example.com/shibboleth',
      'ccdeyjdlashdcdasdfasdf'
    ].join('!')
    user.valid?
    expect(user.errors[:name]).to be_empty
  end

  it "should save the plain password in memory" do
    expect(User.new(:password => 'secret').plain_password).to eql("secret")
  end
  
  it "should generate a password on creation" do
    user = User.create(:name => 'john', :email => 'john.doe@example.com')
    expect(user.password).not_to be_blank
  end

  it "should accept 'john.doe@example-dash.com' as email address" do
    u = FactoryGirl.build :jdoe, :email => 'john.doe@example-dash.com'
    expect(u.valid?).to be_truthy
  end

  it "should keep the three most recent login times" do
    times = [
      Time.parse('2009-09-11 15:15'),
      Time.parse('2009-09-11 15:30'),
      Time.parse('2009-09-11 15:45'),
      Time.parse('2009-09-11 15:55')
    ]

    allow(Kor).to receive(:now).and_return(
      times[0], times[1], times[2], times[3]
    )

    u = User.new
    
    u.add_login_attempt
    expect(u.login_attempts).to eql([times[0]])
    u.add_login_attempt
    expect(u.login_attempts).to eql([times[0], times[1]])
    u.add_login_attempt
    expect(u.login_attempts).to eql([times[0], times[1], times[2]])
    u.add_login_attempt
    expect(u.login_attempts).to eql([times[1], times[2], times[3]])
  end
  
  it "should report too many login attempts when three of them were made in one hour" do
    times = [
      Time.parse('2009-09-11 15:15'),
      Time.parse('2009-09-11 15:30'),
      Time.parse('2009-09-11 15:45'),
      Time.parse('2009-09-11 15:55'),
      Time.parse('2009-09-11 16:16')
    ]

    allow(Kor).to receive(:now).and_return(times[3])
    user = User.new :login_attempts => times[0..2]
    expect(user.too_many_login_attempts?).to be_truthy

    allow(Kor).to receive(:now).and_return(times[4])
    expect(user.too_many_login_attempts?).to be_falsey
  end

  it "should respect inherited global roles" do
    jdoe = FactoryGirl.create :jdoe, :admin => true
    hmustermann = FactoryGirl.create :hmustermann, :parent => jdoe, :relation_admin => true

    hmustermann = User.last
    expect(hmustermann.parent_username).to eq("jdoe")

    expect(hmustermann.admin?).to be_truthy
    expect(hmustermann.kind_admin?).to be_falsey
    expect(hmustermann.relation_admin?).to be_truthy
    expect(hmustermann.authority_group_admin?).to be_falsey
  end

  it "should respect inherited activation status" do
    jdoe = FactoryGirl.create :jdoe, :active => true
    hmustermann = FactoryGirl.create :hmustermann, :parent => jdoe
    expect(hmustermann.reload.active).to be_truthy

    jdoe.update_attributes :active => false
    expect(hmustermann.reload.active).to be_falsey

    hmustermann.update_attributes :active => true
    expect(hmustermann.reload.active).to be_truthy
  end

  it "should respect inherited expiry" do
    time = 2.weeks.from_now
    time = time.change :usec => 0
    jdoe = FactoryGirl.create :jdoe, :expires_at => time
    hmustermann = FactoryGirl.create :hmustermann, :parent => jdoe
    expect(hmustermann.reload.expires_at).to eq(time)

    time = 3.weeks.from_now
    time = time.change :usec => 0
    hmustermann.update_attributes :expires_at => time
    expect(hmustermann.reload.expires_at).to eq(time)
  end

end
