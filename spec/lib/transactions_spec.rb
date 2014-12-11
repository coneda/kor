require 'spec_helper'

describe 'Transactions' do
  include DataHelper
  
  before :each do
    test_data_for_auth
    test_kinds
  end
  
  it "should be delivering consistent data for reloads" do
    Entity.transaction do
      FactoryGirl.create :person
      Entity.first.name.should == 'A person'
    end
  end
  
end
