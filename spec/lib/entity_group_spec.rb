require "spec_helper"

describe EntityGroup do

  include DataHelper
  
  it "should load every kind of entities into the groups, not just images" do
    test_data_for_auth
    test_kinds

    group = FactoryGirl.create :authority_group
    group.add_entities FactoryGirl.create(:leonardo)

    group.entities.count.should eql(1)
  end
  
end
