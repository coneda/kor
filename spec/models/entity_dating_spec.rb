require 'rails_helper'

describe EntityDating do
  include DataHelper
  
  it "factory_girl should create it with the default label" do
    expect(FactoryGirl.build(:entity_dating, :dating_string => "1877").label).to eql("Dating")
  end

  it "should store a dating_string and numerical values for from and for to" do
    dating = FactoryGirl.build(:entity_dating, :dating_string => "1566 bis 1988", :from_day => "1566", :to_day => "1988")
    expect(dating.save).to be_truthy
  end
  
  it "should not save if dating_string can't be parsed" do
    dating = FactoryGirl.build(:entity_dating, :dating_string => "Am Anfang vom 15. Jahrhundert wurde die Kirche gebaut")
    expect(dating.valid?).to be_falsey
    expect(dating.errors).not_to be_empty
  end
  
  it "should not require from and to if dating_string is parsable" do
    dating = FactoryGirl.build(:entity_dating, :dating_string => "15. Jahrhundert")
    expect(dating.save).to be_truthy
  end
  
  it "should parse the dating_string and find values for from and to" do
    dating = FactoryGirl.build(:entity_dating, :dating_string => "15. Jahrhundert")
    expect(dating.from_day).to eql(Date.civil(1400, 1, 1).jd)
    expect(dating.to_day).to eql(Date.civil(1499, 12, 31).jd)
  end
  
  it "should prefer values for to and from to values from the dating_string" do
    dating = FactoryGirl.build(:entity_dating, :dating_string => "15. Jahrhundert", :from_day => "1.1.1420", :to_day => "31.12.1480")
    expect(dating.from_day).to eql(Date.civil(1420, 1, 1).jd)
    expect(dating.to_day).to eql(Date.civil(1480, 12, 31).jd)
  end
  
  it "should not save without a label" do
    dating = FactoryGirl.build(:entity_dating, :label => nil, :dating_string => "15. Jahrhundert")
    expect(dating.save).to be_falsey
  end

  def test_datings
    FactoryGirl.create(:entity_dating, :dating_string => "15. Jahrhundert")
    FactoryGirl.create(:entity_dating, :dating_string => "18. Jahrhundert")
    FactoryGirl.create(:entity_dating, :dating_string => "20. Jahrhundert")
  end
  
  it "should find datings after a given date" do
    test_datings
    expect(EntityDating.after("1480").count).to eql(3)
  end
  
  it "should find datings before a given date" do
    test_datings
    expect(EntityDating.before("1480").count).to eql(1)
  end
  
  it "should find datings between two given dates" do
    test_datings
    expect(EntityDating.between("1750 bis 1950").count).to eql(2)
  end

  it "should parse '1957 bis ?'" do
    today = Date.new 2016, 10, 15
    expect(Kor::Dating::Transform).to receive(:today).twice.and_return(today)

    dating = EntityDating.create(label: "Date", dating_string: "1957 bis ?")
    expect(dating.from_day).to eq(2435840)
    expect(dating.to_day).to eq(2438030)
  end

end
