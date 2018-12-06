require 'rails_helper'

RSpec.describe Fields::Isbn do
  it "should accept '3899427289'" do
    allow(subject).to receive(:value).and_return '3899427289'
    expect(subject.validate_value).to be(true)
  end
  
  it "should accept '9783899427288'" do
    allow(subject).to receive(:value).and_return '9783899427288'
    expect(subject.validate_value).to be(true)
  end
  
  it "should accept '9783837611854'" do
    allow(subject).to receive(:value).and_return '9783837611854'
    expect(subject.validate_value).to be(true)
  end

  it "should accept '978-3-8376-1185-4'" do
    allow(subject).to receive(:value).and_return '978-3-8376-1185-4'
    expect(subject.validate_value).to be(true)
  end
  
end
