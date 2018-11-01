require 'rails_helper'

RSpec.describe Kor::Statistics::Exif do
  it 'should parse camera model and make' do
    picture = FactoryGirl.create :picture_exif
    e = described_class.exif_for(picture)
    expect(e[:make]).to eq('NIKON CORPORATION')
    expect(e[:model]).to eq('NIKON D90')
  end

  it 'should generate a report on camera model and make' do
    picture = FactoryGirl.create :picture_exif
    from = 2.days.ago.strftime('%Y-%m-%d')
    to = Time.now.strftime('%Y-%m-%d')
    stats = described_class.new(from, to)
    stats.run
    expect(stats.report).to match(/NIKON D90: 1/)
  end
end