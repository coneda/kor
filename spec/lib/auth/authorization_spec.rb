require 'spec_helper'

describe Auth::Authorization do
  include DataHelper
  
  it "should say if a user has more than one right" do
    test_data_for_auth
    
    Auth::Authorization.authorized?(@admin, :view, @main).should be_true
    Auth::Authorization.authorized?(@admin, [:view, :edit], @main).should be_true
    Auth::Authorization.authorized?(@admin, [:view, :edit, :approve], @main).should be_true
  end
  
  it "should give all authorized collections for a user and a set of policies" do
    test_data_for_auth
    
    Auth::Authorization.authorized_collections(@admin, :view).should eql([@main])
    Auth::Authorization.authorized_collections(@admin, [:view, :edit]).should eql([@main])
    Auth::Authorization.authorized_collections(@admin, [:view, :edit, :approve]).should eql([@main])
  end

  it "should allow to inherit permissions from another user" do
    hmustermann = FactoryGirl.create :hmustermann
    jdoe = FactoryGirl.create :jdoe
    students = FactoryGirl.create :students
    jdoe.groups << students
    hmustermann.parent = jdoe

    expect(described_class.groups(hmustermann)).to include(students)
  end
  
end
