require 'spec_helper'

describe User do

  it "should save the plain password in memory" do
    User.new(:password => 'secret').plain_password.should eql("secret")
  end
  
  it "should generate a password on creation" do
    user = User.create(:name => 'john', :email => 'john.doe@example.com')
    user.password.should_not be_blank
  end

  it "should accept 'john.doe@example-dash.com' as email address" do
    u = User.make_unsaved :name => 'john', :email => 'john.doe@example-dash.com'
    u.valid?.should be_true
  end

  it "should keep the three most recent login times" do
    times = [
      Time.parse('2009-09-11 15:15'),
      Time.parse('2009-09-11 15:30'),
      Time.parse('2009-09-11 15:45'),
      Time.parse('2009-09-11 15:55')
    ]
  
    Time.should_receive(:now).exactly(4).times.and_return(
      times[0], times[1], times[2], times[3]
    )

    # this should call Time.now 2 times, because somehow, validation callbacks are triggered  
    u = User.new
    
    u.add_login_attempt
    u.login_attempts.should eql([times[0]])
    u.add_login_attempt
    u.login_attempts.should eql([times[0], times[1]])
    u.add_login_attempt
    u.login_attempts.should eql([times[0], times[1], times[2]])
    u.add_login_attempt
    u.login_attempts.should eql([times[1], times[2], times[3]])
  end
  
  it "should report too many login attempts when three of them were made in one hour" do
    times = [
      Time.parse('2009-09-11 15:15'),
      Time.parse('2009-09-11 15:30'),
      Time.parse('2009-09-11 15:45'),
      Time.parse('2009-09-11 15:55'),
      Time.parse('2009-09-11 16:16')
    ]
  
    Time.should_receive(:now).exactly(5).times.and_return(
      times[0], times[1], times[2], times[3], times[4]
    )
  
    # this should call Time.now 2 times, because somehow, validation callbacks are triggered
    u = User.new
   
    u.add_login_attempt
    u.add_login_attempt
    u.add_login_attempt
    
    u.too_many_login_attempts?.should be_true
    
    # one hour later
    u.too_many_login_attempts?.should be_false
  end

  it "should respect inherited global roles" do
    jdoe = FactoryGirl.create :jdoe, :user_admin => true, :collection_admin => true
    hmustermann = FactoryGirl.create :hmustermann, :parent => jdoe, :relation_admin => true

    hmustermann = User.last
    expect(hmustermann.parent_username).to eq("jdoe")

    expect(hmustermann.admin?).to be_false
    expect(hmustermann.user_admin?).to be_true
    expect(hmustermann.kind_admin?).to be_false
    expect(hmustermann.collection_admin?).to be_true
    expect(hmustermann.credential_admin?).to be_false
    expect(hmustermann.relation_admin?).to be_true
    expect(hmustermann.authority_group_admin?).to be_false
  end

end
