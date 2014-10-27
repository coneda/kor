require 'spec_helper'

describe Auth::Authorization do
  include DataHelper
  include AuthHelper

  before :each do
    test_data_for_auth
    test_kinds
  end

  def side_collection
    @side_collection ||= Collection.make(:name => 'Side Collection')
  end
  
  def side_entity(attributes = {})
    @side_entity ||= @person_kind.entities.make attributes.reverse_merge(
      :collection => side_collection, 
      :name => 'Leonardo da Vinci'
    )
  end
  
  def main_entity(attributes = {})
    @main_entity ||= @artwork_kind.entities.make attributes.reverse_merge(
      :collection => @main, 
      :name => 'Mona Lisa'
    )
  end
  
  def set_side_collection_policies(policies = {})
    policies.each do |p, c|
      side_collection.grant p, :to => c
    end
  end
  
  def set_main_collection_policies(policies = {})
    policies.each do |p, c|
      @main.grant p, :to => c
    end
  end
  
  it "should say if a user has more than one right" do
    Auth::Authorization.authorized?(@admin, :view, @main).should be_true
    Auth::Authorization.authorized?(@admin, [:view, :edit], @main).should be_true
    Auth::Authorization.authorized?(@admin, [:view, :edit, :approve], @main).should be_true
  end
  
  it "should give all authorized collections for a user and a set of policies" do
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

  it "should not allow deleting entities without appropriate authorization" do
    set_side_collection_policies :view => [@admins]

    result = described_class.authorized?(User.admin, :delete, side_entity.collection)
    expect(result).to be_false
  end

  it "should not show unauthorized entities" do
    result = described_class.authorized?(User.admin, :view, side_entity.collection)
    expect(result).to be_false
  end

  it "should allow to show authorized entities" do
    set_side_collection_policies :view => [@admins]
    result = described_class.authorized?(User.admin, :view, side_entity.collection)
    expect(result).to be_true
  end

end
