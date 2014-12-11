require 'rails_helper'

RSpec.describe Auth::Authorization do
  include DataHelper

  before :each do
    test_data_for_auth
    test_kinds
  end

  def side_collection
    @side_collection ||= FactoryGirl.create :private
  end
  
  def side_entity(attributes = {})
    @side_entity ||= FactoryGirl.create :leonardo, :collection => side_collection
  end
  
  def main_entity(attributes = {})
    @main_entity ||= FactoryGirl.create :mona_lisa
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
    expect(Auth::Authorization.authorized?(@admin, :view, @main)).to be_truthy
    expect(Auth::Authorization.authorized?(@admin, [:view, :edit], @main)).to be_truthy
    expect(Auth::Authorization.authorized?(@admin, [:view, :edit, :approve], @main)).to be_truthy
  end
  
  it "should give all authorized collections for a user and a set of policies" do
    expect(Auth::Authorization.authorized_collections(@admin, :view)).to eql([@main])
    expect(Auth::Authorization.authorized_collections(@admin, [:view, :edit])).to eql([@main])
    expect(Auth::Authorization.authorized_collections(@admin, [:view, :edit, :approve])).to eql([@main])
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
    expect(result).to be_falsey
  end

  it "should not show unauthorized entities" do
    result = described_class.authorized?(User.admin, :view, side_entity.collection)
    expect(result).to be_falsey
  end

  it "should allow to show authorized entities" do
    set_side_collection_policies :view => [@admins]
    result = described_class.authorized?(User.admin, :view, side_entity.collection)
    expect(result).to be_truthy
  end

end
