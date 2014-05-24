require 'spec_helper'

describe EntityDating do
  include DataHelper
  
  it "machinist should create it with the default label" do
    EntityDating.make_unsaved.dating_string.should eql("1566")
    EntityDating.make_unsaved(:dating_string => "1877").label.should eql("Datierung")
  end

  it "should store a dating_string and numerical values for from and for to" do
    dating = EntityDating.make_unsaved(:dating_string => "1566 bis 1988", :from_day => "1566", :to_day => "1988")
    dating.save.should be_true
  end
  
  it "should not save if dating_string can't be parsed" do
    dating = EntityDating.make_unsaved(:dating_string => "Am Anfang vom 15. Jahrhundert wurde die Kirche gebaut")
    dating.valid?.should be_false
    dating.errors.should_not be_empty
  end
  
  it "should not require from and to if dating_string is parsable" do
    dating = EntityDating.make_unsaved(:dating_string => "15. Jahrhundert")
    dating.save.should be_true
  end
  
  it "should parse the dating_string and find values for from and to" do
    dating = EntityDating.make_unsaved(:dating_string => "15. Jahrhundert")
    dating.from_day.should eql(Date.civil(1400, 1, 1).jd)
    dating.to_day.should eql(Date.civil(1499, 12, 31).jd)
  end
  
  it "should prefer values for to and from to values from the dating_string" do
    dating = EntityDating.make_unsaved(:dating_string => "15. Jahrhundert", :from_day => "1.1.1420", :to_day => "31.12.1480")
    dating.from_day.should eql(Date.civil(1420, 1, 1).jd)
    dating.to_day.should eql(Date.civil(1480, 12, 31).jd)
  end
  
  it "should not save without a label" do
    dating = EntityDating.make_unsaved(:label => nil, :dating_string => "15. Jahrhundert")
    dating.save.should be_false
  end

  def test_datings
    EntityDating.make(:dating_string => "15. Jahrhundert")
    EntityDating.make(:dating_string => "18. Jahrhundert")
    EntityDating.make(:dating_string => "20. Jahrhundert")
  end
  
  it "should find datings after a given date" do
    test_datings
    EntityDating.after("1480").count.should eql(3)
  end
  
  it "should find datings before a given date" do
    test_datings
    EntityDating.before("1480").count.should eql(1)
  end
  
  it "should find datings between two given dates" do
    test_datings
    EntityDating.between("1750 bis 1950").count.should eql(2)
  end
end
