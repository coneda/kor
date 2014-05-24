# encoding: utf-8

require 'spec_helper'

RSpec::Matchers.define :parse do |input|
  match do |parser|
    begin
      parser.parse input
    rescue Parslet::ParseFailed => e
      false
    end
  end
end

describe Dating::Parser do

  def parser
   Dating::Parser.new
  end
  
  it "should parse positive numbers including a zero" do
    parser.positive_number.should parse("0")
    parser.positive_number.should parse("1")
    parser.positive_number.should parse("2134")
    parser.positive_number.should_not parse("02134")
    parser.positive_number.should_not parse("-2")
  end
  
  it "should parse whole numbers" do
   parser.whole_number.should parse("0")
   parser.whole_number.should parse("-10")
   parser.whole_number.should parse("-1")
   
   parser.whole_number.should_not parse("-0")
   parser.whole_number.should_not parse("+0")
  end
  
  it "should parse correctly with it's utility parsers" do
    parser.space.should parse(' ')
    parser.space.should parse('  ')
    parser.space.should_not parse('')
    
    parser.christ.should parse('Christus')
    parser.christ.should parse('Chr.')
    
    parser.age.should parse('v.')
    parser.age.should parse('vor')
  end
  
  it "should parse year numbers" do
    parser.year.should parse('1982')
    parser.year.should parse('2000 v. Chr.')
    parser.year.should parse('1')
    parser.year.should parse('7 vor Christus')
    parser.year.should_not parse('0')
  end
  
  it "should parse century strings" do
    parser.century.should parse('14. Jahrhundert')
    parser.century.should parse('1. Jh. vor Christus')
    parser.century.should_not parse('-1. Jh. v. Chr.')
  end
  
  it "should parse days and months" do
    parser.day.should parse('1')
    parser.day.should parse('29')
    parser.day.should parse('10')
    parser.day.should parse('31')
    parser.day.should_not parse('0')
    parser.day.should_not parse('32')
    
    parser.month.should parse("1")
    parser.month.should parse("7")
    parser.month.should parse("12")
    parser.month.should_not parse("0")
  end
  
  it "should parse '1533'" do
    parser.transform("1533").should eql(
      :from => Date.new(1533, 1, 1),
      :to => Date.new(1533, 12, 31)
    )
  end

  it "should parse 'ca. 1400'" do
    parser.transform("ca. 1400").should eql(
      :from => Date.new(1395, 1, 1),
      :to => Date.new(1405, 12, 31)
    )
  end
  
  it "should parse <century> bis <century>" do
    parser.transform("12. Jh. bis 14. Jh.").should eql(
      :from => Date.new(1100, 1, 1),
      :to => Date.new(1399, 12, 31)
    )
  end
  
  
  it "should parse single dates" do
    parser.transform("20.6.1934").should eql(
      :from => Date.new(1934, 6, 20),
      :to => Date.new(1934, 6, 20)
    )
    
    result = parser.transform("15.4.1982 bis 16.4.1983")
    result.should eql(
      :from => Date.new(1982, 4, 15),
      :to => Date.new(1983, 4, 16)
    )
  end


  it "should parse 'ca. 1400 bis 1480'" do
    parser.transform("ca. 1400 bis 1480").should eql(
      :from => Date.new(1395, 1, 1),
      :to => Date.new(1480, 12, 31)
    )
  end
  
  it "should parse 'ca. 1400 bis ca. 1480'" do
    parser.transform("ca. 1400 bis ca. 1480").should eql(
      :from => Date.new(1395, 1, 1),
      :to => Date.new(1485, 12, 31)
    )
  end
  
  it "should parse '1400 bis ca. 1480'" do
    parser.transform("1400 bis ca. 1480").should eql(
      :from => Date.new(1400, 1, 1),
      :to => Date.new(1485, 12, 31)
    )
  end
  
  it "should parse '? bis 1456'" do
    parser.transform("? bis 1456").should eql(
      :from => Date.new(1456 - (Date.today.year - 1456) / 10, 1, 1),
      :to => Date.new(1456, 12, 31)
    )
  end
  
  it "should parse 'ca. 15. Jahrhundert'" do
    parser.transform("ca. 15. Jahrhundert").should eql(
      :from => Date.new(1375, 1, 1),
      :to => Date.new(1524, 12, 31)
    )
  end
  
  it "it should parse the old unit tests" do
    parser.transform("1289").should eql(:from => Date.new(1289, 1, 1), :to => Date.new(1289, 12, 31))
    parser.transform("ca. 1289").should eql(:from => Date.new(1284, 1, 1), :to => Date.new(1294, 12, 31))
    parser.transform("ca. 1289 v. Chr.").should eql(:from => Date.new(-1294, 1, 1), :to => Date.new(-1284, 12, 31))
    parser.transform("16. Jh.").should eql(:from => Date.new(1500, 1, 1), :to => Date.new(1599, 12, 31))
    parser.transform("16. Jh. v. Chr.").should eql(:from => Date.new(-1599, 1, 1), :to => Date.new(-1500, 12, 31))
    parser.transform("Anfang 16. Jh.").should eql(:from => Date.new(1500, 1, 1), :to => Date.new(1524, 12, 31))
    parser.transform("Mitte 16. Jh.").should eql(:from => Date.new(1535, 1, 1), :to => Date.new(1564, 12, 31))
    parser.transform("Ende 16. Jh.").should eql(:from => Date.new(1575, 1, 1), :to => Date.new(1599, 12, 31))
    parser.transform("1. Hälfte 16. Jh.").should eql(:from => Date.new(1500, 1, 1), :to => Date.new(1549, 12, 31))
    parser.transform("2. Hälfte 16. Jh.").should eql(:from => Date.new(1550, 1, 1), :to => Date.new(1599, 12, 31))
    parser.transform("1. Drittel 16. Jh.").should eql(:from => Date.new(1500, 1, 1), :to => Date.new(1533, 12, 31))
    parser.transform("2. Drittel 16. Jh.").should eql(:from => Date.new(1533, 1, 1), :to => Date.new(1566, 12, 31))
    parser.transform("3. Drittel 16. Jh.").should eql(:from => Date.new(1566, 1, 1), :to => Date.new(1599, 12, 31))
  end
  
end

