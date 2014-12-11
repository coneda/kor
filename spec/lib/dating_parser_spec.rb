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
    expect(parser.positive_number).to parse("0")
    expect(parser.positive_number).to parse("1")
    expect(parser.positive_number).to parse("2134")
    expect(parser.positive_number).not_to parse("02134")
    expect(parser.positive_number).not_to parse("-2")
  end
  
  it "should parse whole numbers" do
   expect(parser.whole_number).to parse("0")
   expect(parser.whole_number).to parse("-10")
   expect(parser.whole_number).to parse("-1")
   
   expect(parser.whole_number).not_to parse("-0")
   expect(parser.whole_number).not_to parse("+0")
  end
  
  it "should parse correctly with it's utility parsers" do
    expect(parser.space).to parse(' ')
    expect(parser.space).to parse('  ')
    expect(parser.space).not_to parse('')
    
    expect(parser.christ).to parse('Christus')
    expect(parser.christ).to parse('Chr.')
    
    expect(parser.age).to parse('v.')
    expect(parser.age).to parse('vor')
  end
  
  it "should parse year numbers" do
    expect(parser.year).to parse('1982')
    expect(parser.year).to parse('2000 v. Chr.')
    expect(parser.year).to parse('1')
    expect(parser.year).to parse('7 vor Christus')
    expect(parser.year).not_to parse('0')
  end
  
  it "should parse century strings" do
    expect(parser.century).to parse('14. Jahrhundert')
    expect(parser.century).to parse('1. Jh. vor Christus')
    expect(parser.century).not_to parse('-1. Jh. v. Chr.')
  end
  
  it "should parse days and months" do
    expect(parser.day).to parse('1')
    expect(parser.day).to parse('29')
    expect(parser.day).to parse('10')
    expect(parser.day).to parse('31')
    expect(parser.day).not_to parse('0')
    expect(parser.day).not_to parse('32')
    
    expect(parser.month).to parse("1")
    expect(parser.month).to parse("7")
    expect(parser.month).to parse("12")
    expect(parser.month).not_to parse("0")
  end
  
  it "should parse '1533'" do
    expect(parser.transform("1533")).to eql(
      :from => Date.new(1533, 1, 1),
      :to => Date.new(1533, 12, 31)
    )
  end

  it "should parse 'ca. 1400'" do
    expect(parser.transform("ca. 1400")).to eql(
      :from => Date.new(1395, 1, 1),
      :to => Date.new(1405, 12, 31)
    )
  end
  
  it "should parse <century> bis <century>" do
    expect(parser.transform("12. Jh. bis 14. Jh.")).to eql(
      :from => Date.new(1100, 1, 1),
      :to => Date.new(1399, 12, 31)
    )
  end
  
  
  it "should parse single dates" do
    expect(parser.transform("20.6.1934")).to eql(
      :from => Date.new(1934, 6, 20),
      :to => Date.new(1934, 6, 20)
    )
    
    result = parser.transform("15.4.1982 bis 16.4.1983")
    expect(result).to eql(
      :from => Date.new(1982, 4, 15),
      :to => Date.new(1983, 4, 16)
    )
  end


  it "should parse 'ca. 1400 bis 1480'" do
    expect(parser.transform("ca. 1400 bis 1480")).to eql(
      :from => Date.new(1395, 1, 1),
      :to => Date.new(1480, 12, 31)
    )
  end
  
  it "should parse 'ca. 1400 bis ca. 1480'" do
    expect(parser.transform("ca. 1400 bis ca. 1480")).to eql(
      :from => Date.new(1395, 1, 1),
      :to => Date.new(1485, 12, 31)
    )
  end
  
  it "should parse '1400 bis ca. 1480'" do
    expect(parser.transform("1400 bis ca. 1480")).to eql(
      :from => Date.new(1400, 1, 1),
      :to => Date.new(1485, 12, 31)
    )
  end
  
  it "should parse '? bis 1456'" do
    expect(parser.transform("? bis 1456")).to eql(
      :from => Date.new(1456 - (Date.today.year - 1456) / 10, 1, 1),
      :to => Date.new(1456, 12, 31)
    )
  end
  
  it "should parse 'ca. 15. Jahrhundert'" do
    expect(parser.transform("ca. 15. Jahrhundert")).to eql(
      :from => Date.new(1375, 1, 1),
      :to => Date.new(1524, 12, 31)
    )
  end
  
  it "it should parse the old unit tests" do
    expect(parser.transform("1289")).to eql(:from => Date.new(1289, 1, 1), :to => Date.new(1289, 12, 31))
    expect(parser.transform("ca. 1289")).to eql(:from => Date.new(1284, 1, 1), :to => Date.new(1294, 12, 31))
    expect(parser.transform("ca. 1289 v. Chr.")).to eql(:from => Date.new(-1294, 1, 1), :to => Date.new(-1284, 12, 31))
    expect(parser.transform("16. Jh.")).to eql(:from => Date.new(1500, 1, 1), :to => Date.new(1599, 12, 31))
    expect(parser.transform("16. Jh. v. Chr.")).to eql(:from => Date.new(-1599, 1, 1), :to => Date.new(-1500, 12, 31))
    expect(parser.transform("Anfang 16. Jh.")).to eql(:from => Date.new(1500, 1, 1), :to => Date.new(1524, 12, 31))
    expect(parser.transform("Mitte 16. Jh.")).to eql(:from => Date.new(1535, 1, 1), :to => Date.new(1564, 12, 31))
    expect(parser.transform("Ende 16. Jh.")).to eql(:from => Date.new(1575, 1, 1), :to => Date.new(1599, 12, 31))
    expect(parser.transform("1. Hälfte 16. Jh.")).to eql(:from => Date.new(1500, 1, 1), :to => Date.new(1549, 12, 31))
    expect(parser.transform("2. Hälfte 16. Jh.")).to eql(:from => Date.new(1550, 1, 1), :to => Date.new(1599, 12, 31))
    expect(parser.transform("1. Drittel 16. Jh.")).to eql(:from => Date.new(1500, 1, 1), :to => Date.new(1533, 12, 31))
    expect(parser.transform("2. Drittel 16. Jh.")).to eql(:from => Date.new(1533, 1, 1), :to => Date.new(1566, 12, 31))
    expect(parser.transform("3. Drittel 16. Jh.")).to eql(:from => Date.new(1566, 1, 1), :to => Date.new(1599, 12, 31))
  end
  
end

