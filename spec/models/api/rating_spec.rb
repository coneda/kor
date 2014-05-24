require 'spec_helper'

describe Api::Rating do

  before :each do
    @user = Factory.create :user
    @admin = Factory.create :admin
    
    @mona_lisa = Factory.create :mona_lisa
    @der_schrei = Factory.create :der_schrei
  end
  
  it "should find less rated entities first" do
    described_class.prepare "2d3d", nil, nil, 5
    described_class.count.should == 2

    ([@mona_lisa, @der_schrei] & described_class.all.map{|r| r.entity}).size.should == 2

    described_class.prepare "2d3d", nil, nil, 5
    described_class.count.should == 4

    described_class.where(:entity_id => @mona_lisa.id).count.should == 2
    described_class.where(:entity_id => @der_schrei.id).count.should == 2

    described_class.prepare "2d3d", nil, nil, 5
    described_class.count.should == 5
  end
   
end
