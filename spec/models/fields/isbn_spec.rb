require 'rails_helper'

RSpec.describe Fields::Isbn do

  it "should accept '3899427289'" do
    expect(subject).not_to receive :add_error
    allow(subject).to receive(:value).and_return '3899427289'
    subject.validate_value
  end
  
  it "should accept '9783899427288'" do
    expect(subject).not_to receive :add_error
    allow(subject).to receive(:value).and_return '9783899427288'
    subject.validate_value
  end
  
  it "should accept '9783837611854'" do
    expect(subject).not_to receive :add_error
    allow(subject).to receive(:value).and_return '9783837611854'
    subject.validate_value
  end

  it "should accept '978-3-8376-1185-4'" do
    expect(subject).not_to receive :add_error
    allow(subject).to receive(:value).and_return '978-3-8376-1185-4'
    subject.validate_value
  end
  
end
