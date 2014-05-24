require "spec_helper"

describe EntityGroup do

  include DataHelper
  
  it "should load every kind of entities into the groups, not just images" do
    test_data_for_auth
    test_kinds
    group = AuthorityGroup.make :name => 'Test Group'
    
    group.add_entities Entity.make(:person, :name => 'Leonardo da Vinci')
    
    group.entities.count.should eql(1)
  end
  
end
