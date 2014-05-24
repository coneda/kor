require 'spec_helper'

describe Fields::Isbn do

  it "should accept '3899427289'" do
    subject.should_not_receive :add_error
    subject.stub(:value).and_return '3899427289'
    subject.validate_value
  end
  
  it "should accept '9783899427288'" do
    subject.should_not_receive :add_error
    subject.stub(:value).and_return '9783899427288'
    subject.validate_value
  end
  
  it "should accept '9783837611854'" do
    subject.should_not_receive :add_error
    subject.stub(:value).and_return '9783837611854'
    subject.validate_value
  end

  it "should accept '978-3-8376-1185-4'" do
    subject.should_not_receive :add_error
    subject.stub(:value).and_return '978-3-8376-1185-4'
    subject.validate_value
  end
  
end
