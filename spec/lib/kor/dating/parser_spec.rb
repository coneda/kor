require 'rails_helper'

RSpec::Matchers.define :parse do |input|
  match do |parser|
    parser.parse input
  rescue Parslet::ParseFailed, Kor::Exception
    false
  end
end

RSpec.describe Kor::Dating::Parser do
  it "should parse positive numbers including a zero" do
    expect(subject.positive_number).to parse("0")
    expect(subject.positive_number).to parse("1")
    expect(subject.positive_number).to parse("2134")
    expect(subject.positive_number).not_to parse("02134")
    expect(subject.positive_number).not_to parse("-2")
  end

  it "should parse whole numbers" do
    expect(subject.whole_number).to parse("0")
    expect(subject.whole_number).to parse("-10")
    expect(subject.whole_number).to parse("-1")

    expect(subject.whole_number).not_to parse("-0")
    expect(subject.whole_number).not_to parse("+0")
  end

  it "should parse correctly with it's utility parsers" do
    expect(subject.space).to parse(' ')
    expect(subject.space).to parse('  ')
    expect(subject.space).not_to parse('')

    expect(subject.christ).to parse('Christus')
    expect(subject.christ).to parse('Chr.')

    expect(subject.age).to parse('v.')
    expect(subject.age).to parse('vor')
  end

  it "should parse year numbers" do
    expect(subject.year).to parse('1982')
    expect(subject.year).to parse('2000 v. Chr.')
    expect(subject.year).to parse('1')
    expect(subject.year).to parse('7 vor Christus')
    expect(subject.year).not_to parse('0')
  end

  it "should parse century strings" do
    expect(subject.century).to parse('14. Jahrhundert')
    expect(subject.century).to parse('1. Jh. vor Christus')
    expect(subject.century).not_to parse('-1. Jh. v. Chr.')
  end

  it "should parse days and months" do
    expect(subject.day).to parse('1')
    expect(subject.day).to parse('29')
    expect(subject.day).to parse('10')
    expect(subject.day).to parse('31')
    expect(subject.day).not_to parse('0')
    expect(subject.day).not_to parse('32')

    expect(subject.month).to parse("1")
    expect(subject.month).to parse("7")
    expect(subject.month).to parse("12")
    expect(subject.month).not_to parse("0")
  end

  it "should parse '1533'" do
    expect(subject.transform("1533")).to eql(
      from: Date.new(1533, 1, 1),
      to: Date.new(1533, 12, 31)
    )
  end

  it "should parse 'ca. 1400'" do
    expect(subject.transform("ca. 1400")).to eql(
      from: Date.new(1395, 1, 1),
      to: Date.new(1405, 12, 31)
    )
  end

  it "should parse <century> bis <century>" do
    expect(subject.transform("12. Jh. bis 14. Jh.")).to eql(
      from: Date.new(1100, 1, 1),
      to: Date.new(1399, 12, 31)
    )
  end

  it "should parse single dates" do
    expect(subject.transform("20.6.1934")).to eql(
      from: Date.new(1934, 6, 20),
      to: Date.new(1934, 6, 20)
    )

    result = subject.transform("15.4.1982 bis 16.4.1983")
    expect(result).to eql(
      from: Date.new(1982, 4, 15),
      to: Date.new(1983, 4, 16)
    )
  end

  it "should parse 'ca. 1400 bis 1480'" do
    expect(subject.transform("ca. 1400 bis 1480")).to eql(
      from: Date.new(1395, 1, 1),
      to: Date.new(1480, 12, 31)
    )
  end

  it "should parse 'ca. 1400 bis ca. 1480'" do
    expect(subject.transform("ca. 1400 bis ca. 1480")).to eql(
      from: Date.new(1395, 1, 1),
      to: Date.new(1485, 12, 31)
    )
  end

  it "should parse '1400 bis ca. 1480'" do
    expect(subject.transform("1400 bis ca. 1480")).to eql(
      from: Date.new(1400, 1, 1),
      to: Date.new(1485, 12, 31)
    )
  end

  it "should parse '? bis 1456'" do
    range = (Date.today.year - 1456) / 10

    expect(subject.transform("? bis 1456")).to eql(
      from: Date.new(1456 - range, 1, 1),
      to: Date.new(1456, 12, 31)
    )
  end

  it "should parse 'vor 1883'" do
    expect(subject.transform('vor 1883')).to eql(
      from: Date.new(1870, 1, 1),
      to: Date.new(1883, 12, 31)
    )
  end

  it "should parse 'nach 1883'" do
    expect(subject.transform('nach 1883')).to eql(
      from: Date.new(1883, 1, 1),
      to: Date.new(1896, 12, 31)
    )
  end

  it "should parse 'nicht vor 1883'" do
    expect(subject.transform('nicht vor 1883')).to eql(
      from: Date.new(1883, 1, 1),
      to: Date.new(1896, 12, 31)
    )
  end

  it "should parse 'nicht nach 1883'" do
    expect(subject.transform('nicht nach 1883')).to eql(
      from: Date.new(1870, 1, 1),
      to: Date.new(1883, 12, 31)
    )
  end

  it "should parse 'um 1555'" do
    expect(subject.transform('um 1555')).to eql(
      from: Date.new(1550, 1, 1),
      to: Date.new(1560, 12, 31)
    )
  end

  it "should parse 'circa 1555'" do
    expect(subject.transform('circa 1555')).to eql(
      from: Date.new(1550, 1, 1),
      to: Date.new(1560, 12, 31)
    )
  end

  it "should parse 'ca. 15. Jahrhundert'" do
    expect(subject.transform("ca. 15. Jahrhundert")).to eql(
      from: Date.new(1375, 1, 1),
      to: Date.new(1524, 12, 31)
    )
  end

  it "should parse '1877.11.02'" do
    expect(subject.transform('1877.11.02')).to eql(
      from: Date.new(1877, 11, 2),
      to: Date.new(1877, 11, 2)
    )
  end

  it "should parse '1877.01.23'" do
    expect(subject.transform('1877.01.23')).to eql(
      from: Date.new(1877, 1, 23),
      to: Date.new(1877, 1, 23)
    )
  end

  it "should parse '1877-01-23'" do
    expect(subject.transform('1877-01-23')).to eql(
      from: Date.new(1877, 1, 23),
      to: Date.new(1877, 1, 23)
    )
  end

  it "it should parse the old unit tests" do
    expect(subject.transform("1289")).to eql(from: Date.new(1289, 1, 1), to: Date.new(1289, 12, 31))
    expect(subject.transform("ca. 1289")).to eql(from: Date.new(1284, 1, 1), to: Date.new(1294, 12, 31))
    expect(subject.transform("ca. 1289 v. Chr.")).to eql(from: Date.new(-1294, 1, 1), to: Date.new(-1284, 12, 31))
    expect(subject.transform("16. Jh.")).to eql(from: Date.new(1500, 1, 1), to: Date.new(1599, 12, 31))
    expect(subject.transform("16. Jh. v. Chr.")).to eql(from: Date.new(-1599, 1, 1), to: Date.new(-1500, 12, 31))
    expect(subject.transform("Anfang 16. Jh.")).to eql(from: Date.new(1500, 1, 1), to: Date.new(1524, 12, 31))
    expect(subject.transform("Mitte 16. Jh.")).to eql(from: Date.new(1535, 1, 1), to: Date.new(1564, 12, 31))
    expect(subject.transform("Ende 16. Jh.")).to eql(from: Date.new(1575, 1, 1), to: Date.new(1599, 12, 31))
    expect(subject.transform("1. Hälfte 16. Jh.")).to eql(from: Date.new(1500, 1, 1), to: Date.new(1549, 12, 31))
    expect(subject.transform("2. Hälfte 16. Jh.")).to eql(from: Date.new(1550, 1, 1), to: Date.new(1599, 12, 31))
    expect(subject.transform("1. Drittel 16. Jh.")).to eql(from: Date.new(1500, 1, 1), to: Date.new(1533, 12, 31))
    expect(subject.transform("2. Drittel 16. Jh.")).to eql(from: Date.new(1533, 1, 1), to: Date.new(1566, 12, 31))
    expect(subject.transform("3. Drittel 16. Jh.")).to eql(from: Date.new(1566, 1, 1), to: Date.new(1599, 12, 31))
  end

  it 'should deal with leap years' do
    expect(subject).to parse('29.2.1996')

    # parsing should work, but the transform should fail
    expect(subject).to parse('29.2.1994')

    expect do
      subject.transform('29.2.1994')
    end.to raise_error(Kor::Exception, '1994 is not a leap year')

    expect do
      expect(subject.transform('29.2.1994 bis 1.2.2013')).to eq(nil)
    end.to raise_error(Kor::Exception, '1994 is not a leap year')
  end
end
