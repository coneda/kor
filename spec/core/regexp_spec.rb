require 'spec_helper'

describe Regexp do
  
  it "should parse a multiple value list" do
    
    regex = /^(image|video|application\/x-shockwave-flash)/
    
    "image/jpg".should match(regex)
    "video/ogg".should match(regex)
    "application/x-shockwave-flash".should match(regex)
    
    "text/html".should_not match(regex)
  end
  
end
