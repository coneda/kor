require 'spec_helper'

describe AuthorityGroup do
  include DataHelper
  
  before :each do
    test_data(:groups => true)
  end
  
  it "should add entities via the << method" do
    group = AuthorityGroup.find_by_name('Sander')
    entity = Entity.find_by_name('Mona Lisa')
    
    group.entities << entity
    AuthorityGroup.find_by_name('Sander').entities.size.should eql(1)
  end
  
end
